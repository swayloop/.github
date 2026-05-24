# swayloop/.github

swayloop org의 공통 표준을 담는 메타 레포입니다.

이 레포는 GitHub의 [community health files](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file) 메커니즘에 의해 org 내 모든 레포에 기본값으로 상속됩니다.

## 구조

- `profile/README.md` — github.com/swayloop org 홈에 노출되는 프로필
- `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md` — 모든 레포에 상속
- `.github/ISSUE_TEMPLATE/` — 이슈 템플릿 (모든 레포 기본값)
- `.github/PULL_REQUEST_TEMPLATE.md` — PR 템플릿 (모든 레포 기본값)
- `.github/workflows/` — reusable workflow (다른 레포에서 `uses:` 로 호출: release-please, auto-close-issues, claude-mention, sync-labels)
- `.github/labels.yml` — 라벨 표준
- `docs/` — 설계 및 운영 문서 (워크플로우, 이슈 관리, 프로젝트 표준)

## 설계 중

현재 표준을 설계 중입니다. 다음 문서를 참고하세요:

- [docs/workflow.md](docs/workflow.md) — 브랜치 전략, PR 룰, 릴리즈
- [docs/issue-management.md](docs/issue-management.md) — 이슈/라벨/우선순위/트리아지
- [docs/project-standards.md](docs/project-standards.md) — 프로젝트 공통 표준
