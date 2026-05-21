# Contributing to swayloop projects

> 이 문서는 swayloop org의 모든 레포에 기본 적용됩니다. 개별 레포가 자체 `CONTRIBUTING.md` 를 두면 그 파일이 우선합니다.

## 브랜치 전략

자세한 내용은 [docs/workflow.md](docs/workflow.md) 참고.

- `main` — 항상 배포 가능한 상태
- `feat/*`, `fix/*`, `chore/*`, `docs/*` — 작업 브랜치
- PR 머지는 Squash 기본

## 커밋 메시지

[Conventional Commits](https://www.conventionalcommits.org/) 를 따릅니다.

```
<type>(<scope>): <subject>

<body>
```

`type`: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`, `ci`

## PR

- PR 제목도 Conventional Commits 형식
- 템플릿의 체크리스트를 채울 것
- 최소 1명의 리뷰 승인 후 머지 (solo 작업 시 self-review로 대체 가능)

## 이슈

- 이슈 템플릿(Bug / Feature) 중 적절한 것 선택
- 라벨은 자동 부여 + 트리아지 시 보강
- 자세한 라벨 체계는 [docs/issue-management.md](docs/issue-management.md)
