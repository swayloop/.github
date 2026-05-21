#!/usr/bin/env bash
# 단일 swayloop 레포 또는 org 의 모든 public 레포에 표준 ruleset 을 적용.
#
# Usage:
#   ./scripts/apply-rulesets.sh swayloop/my-repo   # 한 레포만
#   ./scripts/apply-rulesets.sh --all              # 모든 public 레포
#
# 적용되는 ruleset:
#   - main protection: PR 강제, force push/delete 금지, linear history
#   - dev protection: force push/delete 금지
#
# 멱등(idempotent): 같은 이름의 ruleset 이 있으면 PUT 으로 갱신.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULESETS_DIR="$SCRIPT_DIR/rulesets"

apply_ruleset() {
  local repo="$1"
  local file="$2"
  local name
  name=$(jq -r .name "$file")

  # 기존 ruleset 검색
  local existing
  existing=$(gh api "repos/$repo/rulesets" --jq ".[] | select(.name == \"$name\") | .id" 2>/dev/null || echo "")

  if [ -n "$existing" ]; then
    echo "  ↻ updating '$name' (id=$existing)"
    gh api -X PUT "repos/$repo/rulesets/$existing" --input "$file" > /dev/null
  else
    echo "  ＋ creating '$name'"
    gh api -X POST "repos/$repo/rulesets" --input "$file" > /dev/null
  fi
}

apply_all_rulesets() {
  local repo="$1"
  echo "▶ $repo"
  apply_ruleset "$repo" "$RULESETS_DIR/main-protection.json"
  apply_ruleset "$repo" "$RULESETS_DIR/dev-protection.json"
}

if [ $# -lt 1 ]; then
  echo "Usage: $0 <owner/repo> | --all" >&2
  exit 1
fi

if [ "$1" = "--all" ]; then
  gh repo list swayloop --visibility public --limit 100 --json nameWithOwner --jq '.[].nameWithOwner' | \
    while read -r repo; do
      apply_all_rulesets "$repo"
    done
else
  apply_all_rulesets "$1"
fi
