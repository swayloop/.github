# Agent Workflow

swayloop 의 멀티 에이전트 (Claude Code + Codex) 작업 흐름.

> 기본 git/PR/릴리즈 워크플로우는 [workflow.md](./workflow.md), 도구 선택 근거는 [agent-orchestration-choice.md](./agent-orchestration-choice.md) 참고.

## 한 줄 요약

GitHub 이슈를 사람이 작성 → ai 에이전트 에서 `/issue <N>` 트리거 → 오케스트레이터가 워크트리/브랜치/에이전트 자동 셋업 → 워커가 격리된 환경에서 자율 작업 → 사람이 검토 후 머지.

## 흐름

```
┌─────────────────────────────────────────────────────────────────┐
│  1. 사람                                                         │
│     GitHub 에 이슈 작성 + type 라벨 (feature/bug/docs/...)       │
│     예: 이슈 #2 [type: docs] "README 설치 섹션 추가"             │
└──────────────────────────────┬──────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│  2. 사람 (Claude Code 안에서)                                    │
│     /issue 2  ← 슬래시 커맨드                                    │
└──────────────────────────────┬──────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│  3. 현재 Claude (= 오케스트레이터, dispatcher 역할)              │
│     ① gh issue view 2 → title/body/labels 받음                  │
│     ② type 라벨로 브랜치명 결정 → docs/2-readme-install         │
│     ③ prompt 파일 작성 (이슈 본문 + 컨벤션)                     │
│     ④ workmux add docs/2-readme-install -b -P <prompt> -a claude│
└──────────────────────────────┬──────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│  4. workmux                                                      │
│     ① git worktree add (새 폴더 + 새 브랜치)                    │
│     ② tmux 세션/윈도우 생성                                     │
│     ③ Claude (또는 Codex) 인스턴스 spawn                        │
│     ④ prompt 자동 주입 → 워커 자율 작업 시작                    │
└──────────────────────────────┬──────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│  5. 워커 에이전트 (격리된 worktree 안)                           │
│     • 이슈 본문 읽고 acceptance criteria 따라 코드 변경         │
│     • husky/commitlint 가 강제하는 컨벤션대로 commit            │
│     • PR 만들거나 (/open-pr), 머지 (/merge) — 사람이 검토 후    │
└─────────────────────────────────────────────────────────────────┘
```

## 역할 분리 — 같은 Claude 가 두 모드

| 역할 | 누구 | 무엇 |
|---|---|---|
| **사람** | 사장 | 이슈 작성, `/issue N` 트리거, 결과 검토, 최종 머지 |
| **오케스트레이터** | 현재 Claude Code 세션 | 이슈 → 브랜치 → prompt → spawn (**코드 안 봄**) |
| **워커** | spawn 된 새 Claude/Codex | 실제 코드 변경 + commit + PR |

핵심 분리: **오케스트레이터는 코드 안 읽음**. 단순 dispatcher. 실제 일은 워커가 함. 덕분에 메인 세션 컨텍스트가 더러워지지 않고 토큰 효율도 좋음.

## 현재 상태

이 플로우는 현재 **부분 보류** 상태다.

workmux 를 표준 오케스트레이션 도구로 채택하는 방향은 유지한다. 다만 workmux 기반 dispatch 를 모든 repo 의 운영 표준으로 강제하는 것은 아직 보류한다.

`/issue` 슬래시 커맨드는 별도로 만든다. 이 커맨드의 1차 책임은 **GitHub 이슈를 읽고, 이슈별 격리 worktree + tmux/workmux 세션을 할당하는 것**이다. 실제 구현/머지 자동화는 단계적으로 붙인다.

세션 단위는 이슈 1개를 기본으로 하되, 큰 이슈를 sub-task 이슈로 쪼개고 sub-task 별로 별도 세션을 할당하는 방식은 아직 보류한다.

## 슬래시 커맨드: `/issue`

`~/.claude/skills/issue/SKILL.md` (글로벌). swayloop 표준 어댑터.

### 책임

`/issue` 는 작업을 직접 해결하는 커맨드가 아니라 **세션 할당 커맨드**다.

1. GitHub 이슈를 읽는다.
2. 라벨/제목으로 브랜치명을 정한다.
3. 이슈 본문과 repo 규칙으로 워커 prompt 를 만든다.
4. 이슈별 worktree 를 만든다.
5. 이슈별 tmux/workmux 세션을 할당한다.
6. 선택된 에이전트(Claude 또는 Codex)에 prompt 를 주입한다.

### 인자 형식

```
/issue 2                          현재 repo 의 이슈 #2
/issue swayloop/.github#2         다른 repo 의 이슈
/issue 2 --agent codex            agent 강제 지정 (default = claude)
/issue 2 --fork                   현재 대화 컨텍스트를 워커에 fork
/issue 2 --merge                  워커 끝나면 /merge skill 자동 호출
```

### 자동 변환

| 입력 (이슈 라벨) | 출력 (브랜치 type) |
|---|---|
| `type: bug` | `fix` |
| `type: feature` | `feat` |
| `type: chore` | `chore` |
| `type: docs` | `docs` |
| `type: refactor` | `refactor` |

브랜치명 형식: `<type>/<issue#>-<short-slug>` ([workflow.md 의 네이밍 규칙](./workflow.md#브랜치-네이밍-규칙)).

라벨이 없거나 모호하면 **오케스트레이터가 사용자에게 물어봄** (추측 금지).

### 세션 할당 규칙

세션 이름/handle 은 브랜치명에서 파생한다.

```text
Issue: 3
Branch: docs/3-workmux-standard-setup
Session handle: docs-3-workmux-standard-setup
```

기본 할당:

```bash
workmux add docs/3-workmux-standard-setup -b -P <prompt-file> -a claude
```

Codex 로 강제:

```bash
workmux add docs/3-workmux-standard-setup -b -P <prompt-file> -a codex
```

같은 이슈 번호로 이미 열린 workmux 세션이 있으면 중복 생성하지 않는다. 기본은 기존 세션에 attach 하고, 새 세션이 필요하면 사용자에게 확인한다.

## 사람이 워커 보는 법

워커는 백그라운드 tmux 세션에서 돌고 있음. 사람은 다음 명령으로 감시/개입:

```bash
workmux open <handle>             # 워커 tmux 세션에 attach (들어가서 직접 봄)
workmux status                    # 모든 워커 진행 상태 한 번에
workmux status <handle>           # 특정 워커만
workmux capture <handle> -n 50    # 워커 최근 출력 50줄 (attach 없이 확인)
workmux send <handle> "..."       # 워커에게 추가 지시
workmux send <handle> "/merge"    # 워커에게 skill 호출 시키기
workmux dashboard                 # TUI 대시보드로 전체 보기
```

상태 아이콘 (글로벌 config 의 `status_icons`):
- 🤖 working — 작업 중
- 💬 waiting — 사용자 입력 대기
- ✅ done — 완료

## 병렬 dispatch (fan-out)

여러 이슈 동시에:

```
/issue 2
/issue 3
/issue 4
```

각자 독립된 worktree + tmux 세션 + 에이전트로 병렬 작업. 다 끝나면 사람이 PR 별 검토.

더 정교한 코디네이션 (spawn → wait → review → 순차 merge) 은 workmux 의 [`/coordinator`](https://workmux.raine.dev/guide/skills) skill 참고.

## 마무리

워커가 작업 완료 후:

1. **PR 생성**: 워커가 `/open-pr` 호출 → 사람이 GitHub 에서 검토 → squash merge
2. **직접 merge** (가벼운 작업): 워커가 `/merge` 호출 → rebase + merge + worktree 정리

머지 후 cleanup:

```bash
workmux rm --gone                 # 원격 브랜치 사라진 worktree 일괄 정리
```

## 관련 문서

- [workflow.md](./workflow.md) — 기본 git/PR/릴리즈 워크플로우 (브랜치/커밋/머지 컨벤션)
- [agent-orchestration-choice.md](./agent-orchestration-choice.md) — workmux 채택 근거 (AO/claude-squad 검토)
- [issue-management.md](./issue-management.md) — 이슈 트리아주/라벨 운영
- workmux 공식 docs — <https://workmux.raine.dev>
