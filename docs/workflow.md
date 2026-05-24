# Workflow

swayloop org 의 공통 개발 워크플로우입니다. 새 레포는 이 흐름을 따르세요.

> 멀티 에이전트 (Claude Code + Codex) 작업 흐름은 [agent-workflow.md](./agent-workflow.md) 참고.

## 브랜치 전략

```
feature 브랜치 → dev (일상 작업)
dev → main (릴리즈할 때만)
```

- **`main`** — 릴리즈 브랜치. main 으로의 머지는 곧 릴리즈 트리거 ([release-please](changelog-automation.md) 가 PR 자동 생성).
- **`dev`** — 통합 브랜치. 모든 feature 작업이 여기로 머지됨.
- **작업 브랜치** — `dev` 에서 분기, `dev` 로 머지.

main 으로 직접 머지하지 말 것. 일상 작업은 항상 `feature → dev`.

### 브랜치 네이밍 규칙

```
<type>/<issue-number>-<short-description>
```

예시:
- `feat/4-chat-history`
- `fix/2-scraper-retry`
- `chore/7-bump-deps`
- `docs/3-readme-update`

`type` 은 [Conventional Commits 타입](#커밋-메시지) 과 동일. 이슈 번호 필수 (작업의 추적성 확보).

`pre-push` 훅에서 이 규칙을 강제합니다 ([git-hooks 참고](git-hooks.md)).

## 커밋 메시지

[Conventional Commits](https://www.conventionalcommits.org/) 를 따릅니다.

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

**type 목록:** `feat`, `fix`, `refactor`, `docs`, `chore`, `test`, `perf`, `ci`, `style`, `build`, `revert`

**breaking change:** `feat!:` 처럼 `!` 표시, 또는 footer 에 `BREAKING CHANGE: <desc>`.

`commit-msg` 훅에서 `@commitlint/config-conventional` 로 검증합니다.

## PR 룰

### feature → dev PR

- 제목은 Conventional Commits 형식 (예: `feat: 비용 추적 기능 추가`)
- PR 본문에 `Closes #N` 또는 `Fixes #N` 으로 이슈 연결
- CI 통과 필수
- 머지 방식: **Squash merge** (main 의 커밋 메시지가 PR 제목이 되도록)
- 머지 시 `auto-close-issues` 워크플로우가 본문의 `Closes/Fixes/Resolves #N` 패턴을 보고 이슈 자동 close

### dev → main PR (릴리즈)

- 릴리즈 의사결정 시점에 수동으로 생성
- 머지하면 release-please 가 main 위에서 동작 → 릴리즈 PR 자동 생성/업데이트
- 릴리즈 PR 머지 → 태그 + GitHub Release + CHANGELOG 자동 갱신

자세한 흐름은 [changelog-automation.md](changelog-automation.md).

## 릴리즈

- **버전 체계:** [Semver](https://semver.org/lang/ko/)
- **태그:** `v1.2.3`
- **자동화:** [release-please](changelog-automation.md) — Conventional Commits 기반
- **트리거:** `dev → main` 머지

| 커밋 타입 | 버전 bump |
|---|---|
| `fix:` | patch |
| `feat:` | minor |
| `feat!:` / `BREAKING CHANGE` | major |
| `docs:`, `chore:`, `refactor:`, ... | 변경 없음 |

## 자동화 워크플로우

org 공통 reusable workflow 가 [`swayloop/.github/.github/workflows/`](../.github/workflows) 에 있습니다. 각 레포에서 다음과 같이 호출:

```yaml
# .github/workflows/release.yml (in your repo)
name: Release
on:
  push:
    branches: [main]
jobs:
  release:
    uses: swayloop/.github/.github/workflows/release-please.yml@main
```

| Workflow | 용도 | 트리거 |
|---|---|---|
| `release-please.yml` | 릴리즈 PR 자동 생성 | main push |
| `auto-close-issues.yml` | PR 머지 시 이슈 자동 close | PR closed |
| `claude-mention.yml` | `@claude` 멘션 응답 | comment/issue |
| `sync-labels.yml` | org 공통 라벨 동기화 | caller cron/manual |

호출 방식 (caller 가 트리거를 가짐, 호출되는 쪽은 `workflow_call`):

```yaml
# 예: 각 레포의 .github/workflows/release.yml
name: Release
on:
  push:
    branches: [main]
jobs:
  release:
    uses: swayloop/.github/.github/workflows/release-please.yml@main
    permissions:
      contents: write
      pull-requests: write
    with:
      release-type: node
```

각 워크플로우의 입력/시크릿/permission 은 파일 상단 주석에 명시되어 있습니다.

## 브랜치 보호

org 의 public 레포에는 [`scripts/apply-rulesets.sh`](../scripts/apply-rulesets.sh) 으로 다음 ruleset 이 적용됩니다.

**`main` (default branch)**
- PR 강제 (직접 push 불가)
- Force push 금지
- 삭제 금지
- Linear history (squash/rebase only, merge commit 금지)
- Required reviewers / status checks 없음 — solo self-merge 허용

**`dev`**
- Force push 금지
- 삭제 금지

신규 레포 생성 후 다음 한 줄로 적용:
```bash
swayloop-.github/scripts/apply-rulesets.sh swayloop/<new-repo>
```

> Private 레포는 GitHub Free 플랜에서 ruleset 미지원 (Pro/Team 이상 필요).
