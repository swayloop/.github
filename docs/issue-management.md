# Issue Management

> 🚧 설계 중. swayloop org 의 이슈 트리아지 / 라벨 / 우선순위 운영 방식 초안.

## 원칙

1. **이슈 = 작업의 단위.** PR 은 이슈를 닫는 행위.
2. **라벨은 적게, 명확하게.** 같은 의미의 라벨이 둘 있으면 안 됨.
3. **상태는 라벨이 아니라 Project board 로.** 단, `status: triage`, `status: blocked` 같은 *예외 상태* 는 라벨로 표시 (보드 밖에서도 보이도록).

## 라벨 체계

`.github/labels.yml` 에 정의됨. 카테고리:

| Prefix | 용도 | 필수 |
|---|---|---|
| `type:` | bug / feature / chore / docs / refactor | ✅ 1개 |
| `priority:` | p0 / p1 / p2 / p3 | 트리아지 후 ✅ |
| `status:` | triage / in-progress / blocked / needs-review | 상태에 따라 |
| `agent:` | claude / codex / any — 에이전트 라우팅 (Task 양식 dropdown 매핑) | Task 양식만 |
| `parent-task` / `sub-task` / `parallel-ok` | 분해/병렬화 메타 | Task 양식만 |
| `area:` | 개별 레포에서 확장 (e.g. `area: auth`, `area: ui`) | 선택 |
| community | `good first issue`, `help wanted` | 선택 |

### 우선순위 정의

- **p0** — 장애 / 배포 차단 / 보안. 모든 다른 일 멈추고 처리.
- **p1** — 이번 주 안에 끝낼 일.
- **p2** — 이번 사이클(보통 2주) 안에.
- **p3** — Backlog. 언젠가.

## 이슈 양식

세 가지 양식 (`.github/ISSUE_TEMPLATE/`):

| 양식 | 용도 | 작성 주체 |
|---|---|---|
| `bug_report.yml` | 버그 제보 | 사람 |
| `feature_request.yml` | 기능 요청 | 사람 |
| `agent-task.yml` | **에이전트 친화 작업** (분해된 sub-task 또는 명확한 단일 작업) | 사람 or 코디네이터 에이전트 |

`agent-task.yml` 의 필드 (필수: 요약 / 수용 기준, 나머지 선택):
- 수용 기준 (Acceptance Criteria) — binary 체크리스트
- 스코프 in/out (Constraints)
- 관련 파일/심볼
- 의존성 (blocked-by)
- Test plan
- Agent Routing (dropdown: claude/codex/any → `agent:` 라벨 자동 매핑)
- Budget hint (model + max_iterations)

자동 검증/분해 워크플로우 ([swayloop/.github#8](https://github.com/swayloop/.github/issues/8)) 가 새 이슈 생성 시 본문을 검증하고, 큰 작업은 `agent-task.yml` 구조로 sub-issue 자동 분해.

## 트리아지

새 이슈는 자동으로 `status: triage` 가 붙습니다. 다음 순서로 처리:

1. **분류**: `type:` 라벨 확정 (이미 템플릿에서 붙음)
2. **우선순위**: `priority:` 부여
3. **영역**: `area:` 부여 (선택)
4. **할당**: 담당자 지정 또는 `help wanted`
5. `status: triage` 제거

solo 작업 중에는 가볍게 — `type` + `priority` 만 확실히 잡으면 충분.

## 라벨 동기화

org 전체에 동일한 라벨을 유지하려면 [github-label-sync](https://github.com/Financial-Times/github-label-sync) 또는 [crazy-max/ghaction-github-labeler](https://github.com/crazy-max/ghaction-github-labeler) 를 각 레포에서 cron 으로 돌리는 방식이 일반적.

> TODO: 자동 동기화 워크플로우를 `.github/workflows/sync-labels.yml` 로 추가하고, 각 레포가 cron 으로 그걸 호출하는 구조로 갈지 결정.

## Org-wide Project

- org 레벨 [Projects (v2)](https://github.com/orgs/swayloop/projects) 보드를 만들어 여러 레포 이슈를 한 뷰에 모음
- 컬럼 안: Backlog → Triage → Todo → In Progress → Review → Done
- 자동화: 이슈/PR 생성 시 자동 추가, 상태 변경 시 컬럼 이동

> TODO: 보드 이름, 자동화 규칙 확정.

## 결정해야 할 것 (TODO)

- [ ] `area:` 라벨을 org 공통으로 정의할지, 레포별로 둘지
- [ ] Stale 이슈 자동 닫기 정책 (e.g. 60일 무응답 → `stale`, 14일 더 → close)
- [ ] 외부 기여 받는 레포에서 CLA / DCO 필요 여부
