# swayloop/.github

swayloop org의 공통 표준을 담는 메타 레포입니다.

이 레포는 GitHub의 [community health files](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file) 메커니즘에 의해 org 내 모든 레포에 기본값으로 상속됩니다.

## 구조

- `profile/README.md` — github.com/swayloop org 홈에 노출되는 프로필
- `CONTRIBUTING.md`, `SECURITY.md` — 모든 레포에 상속
- `.github/ISSUE_TEMPLATE/` — 이슈 템플릿 (모든 레포 기본값)
- `.github/PULL_REQUEST_TEMPLATE.md` — PR 템플릿 (모든 레포 기본값)
- `.github/workflows/` — reusable workflow ([아래 표](#reusable-workflows) 참고)
- `.github/labels.yml` — 라벨 표준
- `docs/` — 설계 및 운영 문서 (워크플로우, 이슈 관리, 프로젝트 표준)

## Reusable Workflows

다른 레포에서 `uses: swayloop/.github/.github/workflows/<file>@main` 으로 호출합니다.
트리거(`on:`)는 caller 레포가 가지며, 각 파일 상단 주석에 caller 예시가 있습니다.

| Workflow | 하는 일 | caller 트리거 | 주요 입력/시크릿 |
|---|---|---|---|
| `node-pnpm-ci.yml` | Node/pnpm 공통 CI — `format:check`, lint, typecheck, build, test 를 package.json 에 스크립트가 있을 때만 실행 | PR | `node-version` (기본 20), `working-directory`, `ref` (검사할 커밋, 기본은 이벤트 기본값) |
| `pr-source-branch-check.yml` | main 으로의 PR 이 지정 브랜치(기본 `dev`)에서만 오도록 차단 | main 대상 PR | `allowed-source` (기본 dev) |
| `auto-close-issues.yml` | PR 본문의 `Closes/Fixes/Resolves #N` 패턴으로 머지 시 이슈 자동 close | PR closed | `issues: write` 권한 |
| `release-please.yml` | main push 시 릴리즈 PR 자동 생성 → 머지하면 태그 + Release + CHANGELOG | main push | `release-type` (기본 node) |
| `claude-mention.yml` | 이슈/PR 댓글·리뷰의 `@claude` 멘션에 Claude 가 응답 | issue_comment, review 등 | secret `CLAUDE_CODE_OAUTH_TOKEN` 필수 |
| `sync-labels.yml` | `.github/labels.yml` 을 소스로 caller 레포 라벨 동기화 | cron/manual | `labels-path` |

## 설계 중

현재 표준을 설계 중입니다. 다음 문서를 참고하세요:

- [docs/workflow.md](docs/workflow.md) — 브랜치 전략, PR 룰, 릴리즈
- [docs/issue-management.md](docs/issue-management.md) — 이슈/라벨/우선순위/트리아지
- [docs/project-standards.md](docs/project-standards.md) — 프로젝트 공통 표준
