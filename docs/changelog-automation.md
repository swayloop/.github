# Changelog & Release Automation

swayloop org 공통 릴리즈/CHANGELOG 자동화 표준입니다.

## 도구: release-please

Google 이 관리하는 릴리즈 자동화. Conventional Commits 기반.

### 선택 근거

- Conventional Commits + commitlint 가 이미 적용되어 있어 바로 호환
- 설정이 간단 (GitHub Actions workflow 1개 + 설정 파일 2개)
- 커밋 메시지만 잘 쓰면 추가 작업 없이 완전 자동화
- 릴리즈 PR 단계에서 `CHANGELOG.md` 와 `package.json` (또는 해당 언어 매니페스트) 변경을 repo 에 커밋으로 남겨줌
- 릴리즈 PR 이 명시적으로 생성되어 머지 전에 리뷰 가능

## 동작 흐름

```
feature → dev (일상 작업)
   ↓
dev → main (릴리즈 시점)
   ↓
release-please action 동작
   ↓
릴리즈 PR 자동 생성/업데이트
  - CHANGELOG.md 업데이트
  - 버전 매니페스트 갱신
   ↓
릴리즈 PR 머지
   ↓
Git 태그 + GitHub Release 자동 생성
```

## 버전 결정 규칙

| 커밋 타입 | 버전 bump | 예시 |
|---|---|---|
| `fix:` | patch (0.0.x) | `fix: 검색 결과 누락 수정` |
| `feat:` | minor (0.x.0) | `feat: 비용 추적 기능 추가` |
| `feat!:` / `BREAKING CHANGE` | major (x.0.0) | `feat!: API 응답 구조 변경` |
| `docs:`, `chore:`, `refactor:` 등 | 변경 없음 | `docs: README 업데이트` |

## 필요한 파일 (각 레포)

| 파일 | 역할 |
|---|---|
| `.github/workflows/release-please.yml` | workflow (org reusable 호출 권장) |
| `release-please-config.json` | release-type, changelog-path 등 |
| `.release-please-manifest.json` | 현재 버전 추적 (초기값 `0.0.0` 또는 `0.1.0`) |

### `release-please-config.json` (Node 예시)

```json
{
  "packages": {
    ".": {
      "release-type": "node",
      "changelog-path": "CHANGELOG.md",
      "bump-minor-pre-major": true,
      "bump-patch-for-minor-pre-major": true
    }
  }
}
```

`release-type` 은 언어별로 다름: `node`, `python`, `go`, `rust`, `simple` 등. ([공식 목록](https://github.com/googleapis/release-please/blob/main/docs/manifest-releaser.md#releasetype))

### `.release-please-manifest.json`

```json
{ ".": "0.1.0" }
```

### Workflow (org reusable 호출 — 권장)

```yaml
# .github/workflows/release-please.yml
name: Release Please
on:
  push:
    branches: [main]
permissions:
  contents: write
  pull-requests: write
jobs:
  release:
    uses: swayloop/.github/.github/workflows/release-please.yml@main
```

## 0.x → 1.0 정책

`bump-minor-pre-major: true` + `bump-patch-for-minor-pre-major: true` 설정 시 1.0.0 이전에는:
- `feat:` → minor bump 대신 patch bump
- `feat!:` 또는 BREAKING → minor bump (major 가 아니라)

1.0.0 으로 가는 시점에 매니페스트를 수동으로 `1.0.0` 으로 올리고 옵션을 끄면 됩니다.

## 트러블슈팅

**릴리즈 PR 이 안 만들어져요**
- main 에 머지된 커밋이 `feat:`, `fix:`, breaking 중 하나가 있어야 함. `docs:`, `chore:` 만 있으면 PR 안 생성됨.
- Actions 권한: `contents: write`, `pull-requests: write` 필요.

**버전이 안 올라가요**
- `.release-please-manifest.json` 의 현재 버전과 마지막 태그가 일치해야 함.
