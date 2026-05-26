---
name: "🤖 Agent Task"
about: 에이전트 친화적 작업 이슈 (분해된 sub-task 또는 명확한 단일 작업)
title: "[Agent Task] "
labels: ["status: triage"]
---

<!--
에이전트가 자동 처리할 수 있게 가능한 정보를 채워주세요.
필수 (요약 / 수용 기준) 만으로도 OK, 나머지는 채우면 정확도 ↑.
-->

## 요약 *(필수)*

<!-- 무엇을, 왜. 한두 문장 -->

## 수용 기준 (Acceptance Criteria) *(필수)*

<!-- 에이전트가 "끝났다" 판단할 binary 체크리스트 -->

- [ ]
- [ ]

## 스코프 — 다룰 것

<!-- 이 작업이 손댈 영역 (파일/모듈/기능 등) -->

## 스코프 — 다루지 말 것 (Constraints)

<!-- 만지면 안 되는 영역. scope creep 방지. 예: 리팩토링/스타일 변경은 별도 이슈, 다른 모듈 X -->

## 관련 파일 / 심볼

<!-- 워커의 탐색 시간 단축용. 예: src/..., functionName -->

## 의존성 (blocked by)

<!-- 먼저 끝나야 할 다른 이슈 번호. 예: #43, #44 -->

## Test Plan

<!-- 어떻게 검증할지. 예: 기존 테스트 통과, 새 케이스 ... -->

## Agent Routing

<!-- any / claude / codex 중 하나 (자동 워크플로우가 `agent:` 라벨로 매핑) -->

any

## Budget Hint

<!-- 모델 / 최대 iteration. runaway 방지. 예: sonnet, max_iterations=10 -->

## 추가 정보

<!-- 참고 링크, 스크린샷, parent 이슈 번호 등 -->
