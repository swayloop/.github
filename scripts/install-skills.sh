#!/usr/bin/env bash
# install-skills.sh — swayloop/.github 의 skills/ 를 Claude Code + Codex 양쪽에 설치한다.
#
#   전역:      install-skills.sh
#              ~/.claude/skills, ~/.codex/skills 에 메타 repo 로의 심링크 (단일 정본)
#   프로젝트:  install-skills.sh --target /path/to/project
#              <project>/.claude/skills/<name> 에 실제 복사(정본 1벌) +
#              <project>/.codex/skills/<name> 에 상대 심링크
#              → git 에 커밋 가능, 내용은 1벌만 (중복 없음)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

err() { printf 'install-skills: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
install-skills.sh [options]

기본(전역): ~/.claude/skills, ~/.codex/skills 에 메타 repo 로의 심링크.
--target:   프로젝트에 정본 1벌 복사 + 다른 에이전트는 상대 심링크 (커밋 가능, 중복 없음).

Options:
  --target <dir>   프로젝트 경로에 설치.
  --only a,b       특정 스킬만 (쉼표 구분). 기본: skills/ 전체.
  --copy           dedup 없이 모든 대상에 실제 복사 (상대 심링크 대신).
  --force          기존 스킬 항목 덮어쓰기.
  --claude-only    Claude 쪽만 설치.
  --codex-only     Codex 쪽만 설치.
  --list           설치 가능한 스킬 목록만 출력.
  -h, --help
EOF
}

target="" copy=0 force=0 do_claude=1 do_codex=1 only=""
while [ $# -gt 0 ]; do
  case "$1" in
    --target) target="${2:-}"; shift 2 ;;
    --only)   only="${2:-}"; shift 2 ;;
    --copy)   copy=1; shift ;;
    --force)  force=1; shift ;;
    --claude-only) do_codex=0; shift ;;
    --codex-only)  do_claude=0; shift ;;
    --list)
      [ -d "$SKILLS_DIR" ] || err "skills/ 없음: $SKILLS_DIR"
      for d in "$SKILLS_DIR"/*/; do
        [ -f "$d/SKILL.md" ] && printf '  %s\n' "$(basename "$d")"
      done
      exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) err "알 수 없는 옵션: $1" ;;
  esac
done

[ -d "$SKILLS_DIR" ] || err "skills/ 디렉토리 없음: $SKILLS_DIR"

# 활성 에이전트 base 경로 (claude 우선 = 프로젝트 모드의 정본 위치)
prefix="$HOME"
if [ -n "$target" ]; then
  [ -d "$target" ] || err "--target 디렉토리 없음: $target"
  target="$(cd "$target" && pwd)"
  prefix="$target"
fi
declare -a bases=()
[ "$do_claude" -eq 1 ] && bases+=("$prefix/.claude/skills")
[ "$do_codex" -eq 1 ]  && bases+=("$prefix/.codex/skills")
[ "${#bases[@]}" -gt 0 ] || err "설치 대상이 없습니다 (--claude-only/--codex-only 동시 지정?)"

# 설치할 스킬 목록
declare -a skills=()
if [ -n "$only" ]; then
  IFS=',' read -ra want <<< "$only"
  for name in "${want[@]}"; do
    name="$(printf '%s' "$name" | tr -d '[:space:]')"
    [ -f "$SKILLS_DIR/$name/SKILL.md" ] || err "스킬 없음: $name"
    skills+=("$name")
  done
else
  for d in "$SKILLS_DIR"/*/; do
    [ -f "$d/SKILL.md" ] && skills+=("$(basename "$d")")
  done
fi
[ "${#skills[@]}" -gt 0 ] || err "설치할 스킬이 없습니다."

# 기존 대상 처리. 0=진행, 1=건너뜀
prep_dst() {
  local dst="$1"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ "$force" -eq 1 ]; then rm -rf "$dst"; else
      printf '  건너뜀(존재, --force): %s\n' "$dst"; return 1
    fi
  fi
  mkdir -p "$(dirname "$dst")"
  return 0
}
do_copy()    { prep_dst "$2" || return 0; cp -R "$1" "$2"; printf '  ✓ %s (복사)\n' "$2"; }
do_symlink() { prep_dst "$2" || return 0; ln -s "$1" "$2"; printf '  ✓ %s -> %s (심링크)\n' "$2" "$1"; }

printf '설치 — 대상: %s\n\n' "${target:-전역(~)}"

for name in "${skills[@]}"; do
  src="$SKILLS_DIR/$name"
  if [ -z "$target" ]; then
    # 전역: 메타 repo 로의 절대 심링크(단일 정본), 또는 --copy
    for base in "${bases[@]}"; do
      if [ "$copy" -eq 1 ]; then do_copy "$src" "$base/$name"; else do_symlink "$src" "$base/$name"; fi
    done
  else
    # 프로젝트: 첫 base = 정본 실제 복사, 나머지 = 정본으로의 상대 심링크
    canonical="${bases[0]}"
    do_copy "$src" "$canonical/$name"
    canon_rel="../../$(basename "$(dirname "$canonical")")/$(basename "$canonical")/$name"  # 예: ../../.claude/skills/<name>
    i=1
    while [ "$i" -lt "${#bases[@]}" ]; do
      other="${bases[$i]}"
      if [ "$copy" -eq 1 ]; then do_copy "$src" "$other/$name"; else do_symlink "$canon_rel" "$other/$name"; fi
      i=$((i+1))
    done
  fi
done

if [ -n "$target" ]; then
  printf '\n완료. 정본 1벌 + 상대 심링크. git 에 커밋해 팀과 공유.\n'
else
  printf '\n완료. 업데이트는 이 repo 에서 git pull%s.\n' "$([ "$copy" -eq 1 ] && echo ' 후 재실행' || echo ' (심링크라 자동 반영)')"
fi
