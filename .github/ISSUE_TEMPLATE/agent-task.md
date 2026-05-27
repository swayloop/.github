---
name: "🤖 Agent Task"
about: 에이전트 친화적 작업 이슈 (분해된 sub-task 또는 명확한 단일 작업)
title: "[Agent Task] "
labels: ["status: triage"]
---

<!--
Harness Engineering 4축으로 구성된 양식입니다:
  맥락(뭘 해야) · 제한(뭘 하면 안) · 작업 흐름(어떻게) · 검증(잘 했는지)
필수 (요약 / 수용 기준) 만으로도 OK, 나머지는 채우면 정확도 ↑.
참고: docs/issue-management.md
-->

# 맥락 (Context)

## 요약 *(필수)*

<!-- 무엇을, 왜. 한두 문장 -->

## 관련 파일 / 심볼

<!-- 워커의 탐색 시간 단축용. 예: src/..., functionName -->

## 의존성 (blocked by)

<!-- 먼저 끝나야 할 다른 이슈 번호. 예: #43, #44 -->

---

# 제한 (Constraints)

## 스코프 — 다룰 것

<!-- 이 작업이 손댈 영역 (파일/모듈/기능 등) -->

## 스코프 — 다루지 말 것

<!-- 만지면 안 되는 영역. scope creep 방지. 예: 리팩토링/스타일 변경은 별도 이슈, 다른 모듈 X -->

## Escalation 조건

<!--
언제 멈추고 사람한테 물어봐야 하는지. 예:
- AC 만족 못한 채로 max_iterations 도달
- 공개 API / DB 스키마 변경이 필요해짐
- 외부 서비스 키·권한 부족
- 보안 / 라이선스 판단이 필요해짐
-->

---

# 작업 흐름 (Workflow)

## 진행 절차

<!--
어떤 순서/방식으로 일할지. 예:
1. 영향 받는 모듈 식별
2. failing 테스트 작성 → 구현 → 통과
3. 분해 가능하면 sub-task 이슈로 split
체크리스트로 풀어도 OK.
-->

## 병렬화 가능?

<!-- yes / no / partial. partial 이면 어떤 부분이 직렬인지 한 줄. `parallel-ok` 라벨과 매핑 -->

## Agent Routing

<!-- any / claude / codex 중 하나 (자동 워크플로우가 `agent:` 라벨로 매핑) -->

any

## Budget Hint

<!-- 모델 / 최대 iteration. runaway 방지. 예: sonnet, max_iterations=10 -->

---

# 검증 (Verification)

## 수용 기준 (Acceptance Criteria) *(필수)*

<!-- 에이전트가 "끝났다" 판단할 binary 체크리스트 -->

- [ ]
- [ ]

## Test Plan

<!-- 어떻게 검증할지. 예: 기존 테스트 통과, 새 케이스 ... -->

## 검증 주체

<!--
누가 / 무엇이 AC 만족을 확인하는지. 복수 선택 가능.
- agent self-check (테스트 실행, lint 등)
- CI workflow (예: e2e, type-check)
- 사람 review (시각/UX, 보안 판단 등)
기본: CI + 사람 review
-->

---

## 추가 정보

<!-- 참고 링크, 스크린샷, parent 이슈 번호 등 -->
