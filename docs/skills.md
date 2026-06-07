# Skills

swayloop 공통 **에이전트 스킬**. Claude Code 와 Codex 가 같은 오픈 표준 `SKILL.md` 를 쓰므로,
한 폴더로 양쪽에서 동작한다. 정본은 이 repo 의 `skills/`.

## 구조

```
skills/<name>/
  SKILL.md            # 필수. frontmatter(name·description) + 라우터 본문
  references/         # 세부 문서 (필요 시 로드)
  scripts/            # 결정적 작업 (선택)
  agents/openai.yaml  # Codex 전용 인터페이스 (Claude 는 무시)
```

frontmatter 공통/에이전트전용 구분, 호출 방법, 설치 위치는
[`skills/create-skill/references/skill-structure.md`](../skills/create-skill/references/skill-structure.md) 참고.

## 설치

정본은 **에이전트 중립 `.agents/skills`** 에 둔다. Codex·Cursor·Gemini·Copilot 등은 이걸 native scan 한다.
Claude Code 는 `.agents` 를 안 읽으므로 `.claude/skills` 를 그쪽으로 심링크한다. `.codex/skills` 는 만들지 않는다.

```bash
# 1) 이 repo 클론 (정본)
git clone https://github.com/swayloop/.github.git
cd .github

# 2) 전역 설치 — 모든 프로젝트에서 사용
bash scripts/install-skills.sh

# 또는: 특정 프로젝트에만 설치
bash scripts/install-skills.sh --target /path/to/project
```

| 옵션 | 동작 |
|---|---|
| (기본, 전역) | `~/.agents/skills/<name>`(Codex 등) + `~/.claude/skills/<name>`(Claude) 에 메타 repo 로의 심링크 |
| `--target <dir>` | 프로젝트에 설치 — `.agents/skills/<name>` 에 **정본 1벌** + `.claude/skills` → `../.agents/skills` (디렉토리 심링크) |
| `--only a,b` | 특정 스킬만 |
| `--list` | 설치 가능한 스킬 목록 |
| `--copy` | (전역) 심링크 대신 복사 |
| `--force` | 기존 항목 덮어쓰기 |
| `--claude-only` / `--codex-only` | Claude(`.claude`) / Codex(`.agents`) 매핑만 |

**왜 이렇게:** Codex 는 `.agents/skills` 를 native scan, Claude 는 `.claude/skills` 만 읽는다.
그래서 정본을 `.agents/skills` 한 곳에 두고 Claude 용으로만 `.claude/skills` 심링크를 건다 — 내용은 1벌,
`.codex/skills` 불필요. 프로젝트 설치는 git 에 커밋되어 클론 시에도 동작한다.

스킬은 외부 표준 콘텐츠이므로, 프로젝트 설치 시 `.agents/skills/`·`.claude/skills/` 를 프로젝트의
`.prettierignore`·`.eslintignore`(존재할 때만)에 자동 등록해, 포매터/린터 CI 가 vendored 스킬을 검사하지 않게 한다.

호출: Claude Code `/<name>`, Codex `$<name>` 또는 `/skills` (description 매칭 시 자동).

## 새 스킬 만들기

`create-skill` 스킬이 작성 원칙(5원칙)과 양쪽 호환을 강제한다.

```bash
bash skills/create-skill/scripts/create-skill.sh scaffold --name <name> --description "<desc>"
# 채우기 → verify → install
bash skills/create-skill/scripts/create-skill.sh verify  skills/<name>
```

작성 원칙: [`skills/create-skill/references/skill-principles.md`](../skills/create-skill/references/skill-principles.md)

1. 라우팅 규칙 같은 `description`
2. 결정적 작업엔 결정적 코드 (특히 작업 후 스크립트 검증)
3. 간결한 SKILL.md — 본문은 라우터, 세부는 `references/` 로
4. 스킬당 한 작업
5. 구체 예시
