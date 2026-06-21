---
name: issue
description: git 이슈 번호를 기준으로 SwayLoop의 공통 이슈 작업 플로우를 시작할 때 사용한다.
allowed-tools: Bash, Read, Write
---

# issue

이슈 번호를 받아 SwayLoop의 공통 작업 준비 절차를 수행한다.

## 현재 지원 범위

현재는 작업 브랜치 생성까지만 수행한다.

1. 이슈의 `type:` 라벨과 제목을 읽는다.
2. `origin/dev`를 최신화한다.
3. `<type>/<issue-number>-<short-description>` 형식으로 브랜치를 만든다.
4. 생성된 브랜치로 전환하고 결과를 검증한다.

`main`에서 작업 브랜치를 만들거나 `main`으로 직접 머지하지 않는다.

- 실행 방법: `bash scripts/issue.sh --help`
- 호출 예시: `references/example.md`
