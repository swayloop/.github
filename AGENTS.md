# Agents

swayloop org 공통 표준 메타 repo. ISSUE_TEMPLATE / labels / reusable workflows / 운영 docs 가 핵심.

> 작업 영역에 맞는 파일만 필요할 때 read. 처음에 전부 읽지 않음.

| 작업 영역 | 참고 파일 |
|---|---|
| 개요 | [README.md](README.md) |
| git/PR/릴리즈 워크플로우 | [docs/workflow.md](docs/workflow.md) |
| 멀티 에이전트 작업 흐름 | [docs/agent-workflow.md](docs/agent-workflow.md) |
| workmux 채택 ADR | [docs/agent-orchestration-choice.md](docs/agent-orchestration-choice.md) |
| 이슈 양식 / 라벨 | [docs/issue-management.md](docs/issue-management.md) |
| 에이전트가 새 이슈 생성 시 | [.github/ISSUE_TEMPLATE/agent-task.md](.github/ISSUE_TEMPLATE/agent-task.md) — 섹션 채워 `gh issue create --body-file` 로 호출 |
| 릴리즈 자동화 | [docs/changelog-automation.md](docs/changelog-automation.md) |
| 새 레포 표준 | [docs/project-standards.md](docs/project-standards.md) |
| ISSUE_TEMPLATE / labels | [.github/](.github/) |
| Reusable GitHub Actions | [.github/workflows/](.github/workflows/) (release-please, claude-mention, auto-close-issues, sync-labels) |
| 브랜치 보호 스크립트 | [scripts/apply-rulesets.sh](scripts/apply-rulesets.sh) |
