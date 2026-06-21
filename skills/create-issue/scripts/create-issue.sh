#!/usr/bin/env bash
# create-issue.sh — swayloop org 표준 agent-task 이슈 생성의 결정적 작업. (원칙 2)
#   template : org 표준 agent-task.md 를 가져와 frontmatter 를 떼고 body 파일로 저장
#   create   : 라벨 조립 → gh issue create → 생성된 이슈 라벨 사후 검증
set -euo pipefail

VALID_TYPES="bug feature chore docs refactor"
VALID_AGENTS="claude codex any"
VALID_PRIOS="p0 p1 p2 p3"
ORG_REPO="swayloop/.github"
TEMPLATE_PATH=".github/ISSUE_TEMPLATE/agent-task.md"

die() { echo "✗ $*" >&2; exit 1; }
in_list() { local x="$1"; shift; for i in $*; do [ "$i" = "$x" ] && return 0; done; return 1; }

usage() {
  cat <<'EOF'
create-issue.sh <command> [options]

Commands:
  template [--out FILE]
      org 표준 agent-task 템플릿을 가져와 frontmatter 제거 후 저장.
      --out 기본값: /tmp/issue-body.md. 어느 repo 에서 실행하든 org 정본을 받아옴.
      → 이 파일의 <!-- 안내 --> 를 실제 내용으로 채운 뒤 create 로 넘긴다.

  create --title "<요약>" --body-file FILE --type <bug|feature|chore|docs|refactor>
         [--priority <p0|p1|p2|p3>] [--agent <claude|codex|any>] [--area <name>]
         [--repo <owner/name>] [--dry-run]
      라벨(status: triage + type:<type> [+ priority/agent/area])을 조립해
      gh issue create 실행. 생성 후 이슈를 다시 읽어 라벨 누락을 검증한다.
      title 에 "[Agent Task]" prefix 가 없으면 자동으로 붙인다.
      --dry-run 이면 실제 생성 없이 실행할 gh 명령만 출력.

  -h, --help
EOF
}

cmd_template() {
  local out="/tmp/issue-body.md"
  while [ $# -gt 0 ]; do
    case "$1" in
      --out) out="$2"; shift 2;;
      *) die "알 수 없는 옵션: $1";;
    esac
  done
  command -v gh >/dev/null || die "gh CLI가 설치되어 있지 않습니다. https://cli.github.com/ 에서 설치한 뒤 다시 실행하세요."
  gh api "repos/$ORG_REPO/contents/$TEMPLATE_PATH" --jq .content \
    | base64 -d \
    | sed '/^---$/,/^---$/d' \
    > "$out" || die "템플릿을 가져오지 못했습니다."
  [ -s "$out" ] || die "가져온 템플릿이 비었습니다: $out"
  echo "✓ 템플릿 저장: $out"
  echo "  다음: $out 의 <!-- 안내 --> 를 채운 뒤 create --body-file $out 로 생성."
}

cmd_create() {
  local title="" body_file="" type="" priority="" agent="" area="" repo="" dry=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --title) title="$2"; shift 2;;
      --body-file) body_file="$2"; shift 2;;
      --type) type="$2"; shift 2;;
      --priority) priority="$2"; shift 2;;
      --agent) agent="$2"; shift 2;;
      --area) area="$2"; shift 2;;
      --repo) repo="$2"; shift 2;;
      --dry-run) dry=1; shift;;
      *) die "알 수 없는 옵션: $1";;
    esac
  done

  # --- 입력 검증 (결정적) ---
  [ -n "$title" ] || die "--title 필수"
  [ -n "$body_file" ] || die "--body-file 필수"
  [ -f "$body_file" ] || die "body 파일 없음: $body_file"
  [ -s "$body_file" ] || die "body 파일이 비었음: $body_file"
  [ -n "$type" ] || die "--type 필수 ($VALID_TYPES)"
  in_list "$type" "$VALID_TYPES" || die "잘못된 --type '$type' ($VALID_TYPES)"
  [ -z "$priority" ] || in_list "$priority" "$VALID_PRIOS" || die "잘못된 --priority '$priority' ($VALID_PRIOS)"
  [ -z "$agent" ] || in_list "$agent" "$VALID_AGENTS" || die "잘못된 --agent '$agent' ($VALID_AGENTS)"
  grep -q '<!--' "$body_file" && echo "⚠ body 에 <!-- 주석 --> 이 남아있습니다 — 안내문을 실제 내용으로 바꿨는지 확인하세요." >&2
  command -v gh >/dev/null || die "gh CLI가 설치되어 있지 않습니다. https://cli.github.com/ 에서 설치한 뒤 다시 실행하세요."

  # --- title prefix 보정 ---
  case "$title" in
    "[Agent Task]"*) ;;
    *) title="[Agent Task] $title";;
  esac

  # --- 라벨 조립 (status: triage 누락 방지) ---
  local labels=("status: triage" "type: $type")
  [ -n "$priority" ] && labels+=("priority: $priority")
  [ -n "$agent" ] && labels+=("agent: $agent")
  [ -n "$area" ] && labels+=("area: $area")

  local args=(issue create --title "$title" --body-file "$body_file")
  for l in "${labels[@]}"; do args+=(--label "$l"); done
  [ -n "$repo" ] && args+=(--repo "$repo")

  if [ "$dry" = 1 ]; then
    printf 'gh'; printf ' %q' "${args[@]}"; printf '\n'
    return 0
  fi

  # --- 사전 검증: 생성 전에 대상 레포에 필요한 라벨이 있는지 확인 ---
  local target_repo="$repo"
  if [ -z "$target_repo" ]; then
    target_repo="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')" \
      || die "현재 GitHub 저장소를 확인하지 못했습니다. --repo <owner/name>을 지정하세요."
  fi

  local existing_labels
  existing_labels="$(gh label list --repo "$target_repo" --limit 100 --json name --jq '.[].name')" \
    || die "라벨 목록을 가져오지 못했습니다: $target_repo"

  local missing_labels=()
  for l in "${labels[@]}"; do
    grep -Fxq "$l" <<<"$existing_labels" || missing_labels+=("$l")
  done

  if [ "${#missing_labels[@]}" -gt 0 ]; then
    echo "✗ 대상 저장소에 필요한 라벨이 없습니다: ${missing_labels[*]}" >&2
    echo "  → $target_repo 저장소의 sync-labels 워크플로우를 먼저 실행하세요." >&2
    echo "  → 예: gh workflow run sync-labels.yml --repo $target_repo" >&2
    exit 1
  fi

  # --- 생성 ---
  local url
  url="$(gh "${args[@]}")" || die "이슈 생성 실패"
  echo "✓ 생성됨: $url"

  # --- 사후 검증: 생성된 이슈를 다시 읽어 라벨 불변식 assert (원칙 2) ---
  local view_args=(issue view "$url" --json labels --jq '.labels[].name')
  local got
  got="$(gh "${view_args[@]}")" || { echo "⚠ 검증 skip: 이슈를 다시 읽지 못함" >&2; return 0; }
  local missing=0
  for l in "${labels[@]}"; do
    if ! grep -Fxq "$l" <<<"$got"; then
      echo "✗ 라벨 누락: '$l' (레포에 라벨이 없거나 동기화 안 됨)" >&2
      missing=1
    fi
  done
  if [ "$missing" = 1 ]; then
    echo "  → 레포에 sync-labels 워크플로우가 돌았는지 확인. gh label list 로 점검." >&2
    exit 1
  fi
  echo "✓ 라벨 검증 통과: ${labels[*]}"
}

case "${1:-}" in
  template) shift; cmd_template "$@";;
  create) shift; cmd_create "$@";;
  -h|--help|"") usage;;
  *) die "알 수 없는 명령: $1 (template|create)";;
esac
