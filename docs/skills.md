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

`scripts/install-skills.sh` 가 `skills/` 를 Claude Code(`~/.claude/skills`)와
Codex(`~/.codex/skills`) 양쪽에 설치한다. 기본은 **심링크**라 이 repo 를 `git pull` 하면 자동 반영.

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
| (기본, 전역) | `~/.claude/skills`, `~/.codex/skills` 에 **메타 repo 로의 심링크** (단일 정본) |
| `--target <dir>` | 프로젝트에 설치 — `.claude/skills/<name>` 에 **실제 1벌** + `.codex/skills/<name>` 은 **상대 심링크** |
| `--only a,b` | 특정 스킬만 |
| `--list` | 설치 가능한 스킬 목록 |
| `--copy` | dedup 없이 모든 대상에 실제 복사 (상대 심링크 대신) |
| `--force` | 기존 항목 덮어쓰기 |
| `--claude-only` / `--codex-only` | 한쪽만 |

Claude 와 Codex 는 각자 디렉토리(`.claude/skills`·`.codex/skills`)를 스캔하므로 양쪽에 항목이 있어야 한다.
중복을 피하려고 **내용은 1벌만 두고 다른 쪽은 상대 심링크**로 가리킨다 — 전역은 메타 repo 로의 심링크,
프로젝트(`--target`)는 `.claude` 정본 1벌 + `.codex` 상대 심링크(git 에 커밋되어 클론 시 동작).

스킬은 외부 표준 콘텐츠이므로, 프로젝트 설치 시 스킬 디렉토리(`.claude/skills/`, `.codex/skills/`)를
프로젝트의 `.prettierignore`·`.eslintignore`(존재할 때만)에 자동 등록해, 포매터/린터 CI 가
vendored 스킬을 검사하지 않게 한다.

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
