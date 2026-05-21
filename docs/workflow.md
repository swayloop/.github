# Workflow

> 🚧 설계 중입니다. 이 문서는 swayloop 프로젝트들의 공통 개발 워크플로우 초안입니다.

## 브랜치 전략

기본은 **trunk-based** 입니다. 장기 브랜치를 피하고 짧게 머지하는 걸 선호합니다.

- `main` — 항상 배포 가능한 상태. 직접 푸시 금지, PR 만 허용.
- `feat/<scope>-<short>` — 새 기능
- `fix/<scope>-<short>` — 버그 수정
- `chore/<scope>-<short>` — 잡일 (deps, ci, config)
- `docs/<scope>-<short>` — 문서
- `refactor/<scope>-<short>` — 리팩터

예: `feat/auth-google-oauth`, `fix/api-rate-limit-edge-case`

## 커밋 메시지

[Conventional Commits](https://www.conventionalcommits.org/).

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

- `type` 은 라벨/CHANGELOG 자동화에 사용 → 빠뜨리지 말 것
- breaking change 는 footer 에 `BREAKING CHANGE: <desc>` 또는 type 뒤에 `!`

## PR 룰

- **제목** 도 Conventional Commits 형식 (squash merge 시 main 의 커밋 메시지가 됨)
- 템플릿 체크리스트 모두 채우기
- CI 통과 필수
- solo 작업이면 self-review 후 머지 가능
- 머지 방식: **Squash merge** 기본 (히스토리 단순)

## 릴리즈

> TODO: 프로젝트별로 다를 수 있음. 공통 가이드 정리 필요.

- Semver
- 태그 형식: `v1.2.3`
- Release notes 는 GitHub Releases 의 auto-generate 기반, Conventional Commits 라벨로 분류

## CI/CD

- 공통 CI 는 `swayloop/.github` 의 reusable workflow 사용 권장
- 예: `uses: swayloop/.github/.github/workflows/<name>.yml@main`
- 현재 정의된 reusable workflow: *(TODO)*

## 결정해야 할 것 (TODO)

- [ ] 브랜치 보호 규칙: required reviewers, status checks, linear history?
- [ ] 머지 방식: squash 외에 rebase 도 허용할지
- [ ] 버전 태깅: 자동(release-please/changesets) vs 수동
- [ ] Conventional Commits 강제 (commitlint) 도입 여부
