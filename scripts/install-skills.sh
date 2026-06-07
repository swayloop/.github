#!/usr/bin/env bash
# install-skills.sh — swayloop/.github 의 skills/ 를 에이전트들이 쓸 수 있게 설치한다.
#
# 정본은 에이전트 중립 .agents/skills (Codex·Cursor·Gemini·Copilot 등이 native scan).
# Claude Code 는 .agents 를 읽지 않으므로 .claude/skills 를 그쪽으로 심링크한다.
# Codex 는 .agents/skills 를 native scan 하므로 .codex/skills 는 만들지 않는다.
#
#   전역:      install-skills.sh
#              ~/.agents/skills/<name> (Codex 등) + ~/.claude/skills/<name> (Claude)
#              둘 다 메타 repo 로의 심링크 (단일 정본)
#   프로젝트:  install-skills.sh --target /path/to/project
#              <p>/.agents/skills/<name>/ 실제 1벌 (정본) +
#              <p>/.claude/skills -> ../.agents/skills (디렉토리 심링크)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

err() { printf 'install-skills: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
install-skills.sh [options]

정본: .agents/skills (에이전트 중립). Claude=.claude/skills 심링크, Codex=.agents native scan.

  전역(기본):  ~/.agents/skills, ~/.claude/skills 에 메타 repo 로의 심링크.
  --target D:  D/.agents/skills 에 정본 복사 + D/.claude/skills 심링크.

Options:
  --target <dir>   프로젝트에 설치.
  --only a,b       특정 스킬만 (쉼표 구분). 기본: skills/ 전체.
  --copy           (전역) 심링크 대신 복사.
  --force          기존 항목 덮어쓰기.
  --claude-only    Claude 매핑만 (.claude/skills).
  --codex-only     Codex 매핑만 (.agents/skills).
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
[ "$do_claude" -eq 1 ] || [ "$do_codex" -eq 1 ] || err "설치 대상이 없습니다 (--claude-only/--codex-only 동시 지정?)"

if [ -n "$target" ]; then
  [ -d "$target" ] || err "--target 디렉토리 없음: $target"
  target="$(cd "$target" && pwd)"
fi

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

if [ -z "$target" ]; then
  # 전역: ~/.agents(Codex 등), ~/.claude(Claude). 둘 다 메타 repo 로의 심링크(또는 --copy).
  for name in "${skills[@]}"; do
    src="$SKILLS_DIR/$name"
    if [ "$do_codex" -eq 1 ]; then
      if [ "$copy" -eq 1 ]; then do_copy "$src" "$HOME/.agents/skills/$name"; else do_symlink "$src" "$HOME/.agents/skills/$name"; fi
    fi
    if [ "$do_claude" -eq 1 ]; then
      if [ "$copy" -eq 1 ]; then do_copy "$src" "$HOME/.claude/skills/$name"; else do_symlink "$src" "$HOME/.claude/skills/$name"; fi
    fi
  done
else
  # 프로젝트(Phase D): .agents/skills 가 정본(실제 복사), .claude/skills 는 디렉토리 심링크.
  for name in "${skills[@]}"; do
    do_copy "$SKILLS_DIR/$name" "$target/.agents/skills/$name"
  done
  if [ "$do_claude" -eq 1 ]; then
    do_symlink "../.agents/skills" "$target/.claude/skills"   # Claude 가 .agents 를 못 읽어 심링크
  fi
  # Codex 는 .agents/skills 를 native scan → 별도 매핑 불필요

  # vendored 스킬을 프로젝트 포매터/린터가 건드리지 않게 ignore 등록 (있을 때만)
  ignore_entry() {
    local file="$1" entry="$2"
    if [ ! -f "$file" ] || ! grep -qxF "$entry" "$file"; then
      printf '%s\n' "$entry" >> "$file"; printf '  + %s: %s\n' "$(basename "$file")" "$entry"
    fi
  }
  for ig in "$target/.prettierignore" "$target/.eslintignore"; do
    [ -e "$ig" ] || continue
    ignore_entry "$ig" ".agents/skills/"
    [ "$do_claude" -eq 1 ] && ignore_entry "$ig" ".claude/skills/"
  done
fi

if [ -n "$target" ]; then
  printf '\n완료. 정본 .agents/skills + Claude 심링크. Codex 는 .agents 를 native scan. git 에 커밋해 공유.\n'
else
  printf '\n완료 (~/.agents = Codex 등, ~/.claude = Claude). 업데이트는 이 repo 에서 git pull%s.\n' "$([ "$copy" -eq 1 ] && echo ' 후 재실행' || echo ' (심링크라 자동 반영)')"
fi
