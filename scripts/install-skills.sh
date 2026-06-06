#!/usr/bin/env bash
# install-skills.sh — swayloop/.github 의 skills/ 를 Claude Code + Codex 양쪽에 설치한다.
#
#   전역 설치:     install-skills.sh
#                  → ~/.claude/skills, ~/.codex/skills
#   프로젝트 설치:  install-skills.sh --target /path/to/project
#                  → <project>/.claude/skills, <project>/.codex/skills
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

err() { printf 'install-skills: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
install-skills.sh [options]

기본(전역): ~/.claude/skills 와 ~/.codex/skills 에 설치.

Options:
  --target <dir>   프로젝트 경로. <dir>/.claude/skills, <dir>/.codex/skills 에 설치.
  --only a,b       특정 스킬만 (쉼표 구분). 기본: skills/ 전체.
  --copy           심링크 대신 복사 (프로젝트에 커밋하려면 권장).
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

# 설치 대상 base 경로 결정
declare -a bases=()
if [ -n "$target" ]; then
  [ -d "$target" ] || err "--target 디렉토리 없음: $target"
  target="$(cd "$target" && pwd)"
  [ "$do_claude" -eq 1 ] && bases+=("$target/.claude/skills")
  [ "$do_codex" -eq 1 ]  && bases+=("$target/.codex/skills")
else
  [ "$do_claude" -eq 1 ] && bases+=("$HOME/.claude/skills")
  [ "$do_codex" -eq 1 ]  && bases+=("$HOME/.codex/skills")
fi
[ "${#bases[@]}" -gt 0 ] || err "설치 대상이 없습니다 (--claude-only/--codex-only 동시 지정?)"

# 설치할 스킬 목록 결정
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

mode="심링크"; [ "$copy" -eq 1 ] && mode="복사"
printf '설치 (%s) — 대상: %s\n\n' "$mode" "${target:-전역(~)}"

for base in "${bases[@]}"; do
  mkdir -p "$base"
  for name in "${skills[@]}"; do
    src="$SKILLS_DIR/$name"
    dst="$base/$name"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
      if [ "$force" -eq 1 ]; then rm -rf "$dst"; else
        printf '  건너뜀(존재, --force): %s\n' "$dst"; continue
      fi
    fi
    if [ "$copy" -eq 1 ]; then
      cp -R "$src" "$dst"
    else
      ln -s "$src" "$dst"
    fi
    printf '  ✓ %s\n' "$dst"
  done
done

printf '\n완료. 업데이트는 이 repo 에서 git pull%s.\n' "$([ "$copy" -eq 1 ] && echo ' 후 재실행' || echo ' (심링크라 자동 반영)')"
