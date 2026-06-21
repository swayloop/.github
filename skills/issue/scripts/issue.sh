#!/usr/bin/env bash
# issue.sh — GitHub 이슈를 origin/dev 기준 작업 브랜치로 변환한다.
set -euo pipefail

die() { echo "✗ $*" >&2; exit 1; }

usage() {
  printf '%s\n' \
    'issue.sh <issue-number> [options]' \
    '' \
    'Options:' \
    '  --slug <short-kebab-name>  브랜치 설명. 생략하면 이슈 제목에서 생성' \
    '  --dry-run                 이슈를 읽고 생성할 브랜치만 출력' \
    '  -h, --help               도움말'
}

slugify() {
  local value="$1"
  value="$(printf '%s' "$value" | sed -E 's/^\[Agent Task\][[:space:]]*//')"
  value="$(printf '%s' "$value" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g')"
  printf '%s' "${value:-task}"
}

issue_ref=""
slug=""
dry_run=0

while [ $# -gt 0 ]; do
  case "$1" in
    --slug) slug="${2:-}"; shift 2;;
    --dry-run) dry_run=1; shift;;
    -h|--help) usage; exit 0;;
    -*) die "알 수 없는 옵션: $1";;
    *)
      [ -z "$issue_ref" ] || die "이슈는 하나만 지정할 수 있습니다."
      issue_ref="$1"
      shift
      ;;
  esac
done

[ -n "$issue_ref" ] || { usage; die "이슈 번호가 필요합니다."; }

command -v gh >/dev/null || die "gh CLI가 없습니다. https://cli.github.com/ 에서 설치하세요."
command -v git >/dev/null || die "git이 필요합니다."
git rev-parse --show-toplevel >/dev/null 2>&1 || die "Git 저장소 안에서 실행하세요."

[[ "$issue_ref" =~ ^[0-9]+$ ]] || die "이슈 번호는 숫자여야 합니다: $issue_ref"
issue_number="$issue_ref"
repo="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')" \
  || die "현재 GitHub 저장소를 확인하지 못했습니다."

title="$(gh issue view "$issue_number" --repo "$repo" --json title --jq '.title')" \
  || die "이슈 제목을 읽지 못했습니다: $repo#$issue_number"
url="$(gh issue view "$issue_number" --repo "$repo" --json url --jq '.url')" \
  || die "이슈 URL을 읽지 못했습니다: $repo#$issue_number"
labels="$(gh issue view "$issue_number" --repo "$repo" --json labels --jq '.labels[].name')" \
  || die "이슈 라벨을 읽지 못했습니다: $repo#$issue_number"

type_labels="$(printf '%s\n' "$labels" | grep '^type: ' || true)"
type_count="$(printf '%s\n' "$type_labels" | sed '/^$/d' | wc -l | tr -d ' ')"
[ "$type_count" = "1" ] || die "type: 라벨이 정확히 하나 필요합니다. 현재 ${type_count}개"

case "$type_labels" in
  'type: feature') branch_type="feat";;
  'type: bug') branch_type="fix";;
  'type: chore') branch_type="chore";;
  'type: docs') branch_type="docs";;
  'type: refactor') branch_type="refactor";;
  *) die "지원하지 않는 type 라벨: $type_labels";;
esac

[ -n "$slug" ] || slug="$(slugify "$title")"
[[ "$slug" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] \
  || die "--slug는 영문 소문자 kebab-case여야 합니다: $slug"

branch="$branch_type/$issue_number-$slug"

if [ "$dry_run" = 1 ]; then
  printf 'Issue: %s\nBranch: %s\nBase: origin/dev\n' "$url" "$branch"
  exit 0
fi

[ -z "$(git status --porcelain)" ] \
  || die "작업 디렉터리에 미커밋 변경이 있습니다. 정리한 뒤 다시 실행하세요."
git show-ref --verify --quiet "refs/heads/$branch" \
  && die "로컬 브랜치가 이미 존재합니다: $branch"
git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1 \
  && die "원격 브랜치가 이미 존재합니다: origin/$branch"

git fetch origin dev || die "origin/dev를 가져오지 못했습니다."
git show-ref --verify --quiet refs/remotes/origin/dev \
  || die "origin/dev 브랜치가 없습니다."
git switch --no-track -c "$branch" origin/dev \
  || die "브랜치 생성에 실패했습니다: $branch"

current_branch="$(git branch --show-current)"
[ "$current_branch" = "$branch" ] \
  || die "생성 후 현재 브랜치가 예상과 다릅니다: $current_branch"

printf '✓ 작업 브랜치 생성 완료\nIssue: %s\nBranch: %s\nBase: origin/dev\n' "$url" "$branch"
