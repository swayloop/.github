# 에이전트 오케스트레이션 도구 선택 — workmux

> 결정 기록 · 2026-05-23 · 관련 이슈 [#3](https://github.com/swayloop/.github/issues/3)

## 결정

swayloop 의 메인 에이전트 오케스트레이션 도구로 **workmux** 를 사용한다.
ComposioHQ/agent-orchestrator(AO), smtg-ai/claude-squad 등 후보를 dogfooding 으로 검증한 뒤 회귀한 결정.

## 배경

swayloop 는 Claude Code + Codex 를 git worktree 격리 환경에서 병렬로 운영하는 것이 목표. 다음 요구를 동시에 충족하는 도구가 필요했다.

1. tmux + git worktree 기반 (이미 익숙한 패턴)
2. **짝코딩** (사람이 옆에서 같이 작업) + **자동화** (에이전트가 도구 호출) 두 모드 모두 가능
3. Claude / Codex 등 여러 에이전트 지원
4. swayloop 컨벤션 (Conventional Commits, `<type>/<issue#>-<desc>` 브랜치 명명) 와 충돌 없음
5. 운영 안정성 — production 도입 마찰 적음

## 검토한 도구들

### 1. ComposioHQ/agent-orchestrator (AO) — 보류

**모델**: 풀스택 자율 워커. 이슈 감지 → 워커 spawn → CI/리뷰 자동 라우팅 → PR 자동 생성.

**장점**

- 7-layer harness 의 L1(이슈) / L4(validation) / L5(PR) 까지 통합
- 풍부한 config (per-worker agent, model, agentRules)
- 7.2k stars, Composio 회사 $29M Series A funded, 메인 product (composio) 28k stars

**문제** (v0.9.1 dogfooding, 2026-05-23)

- **Project ID auto-hash mismatch** — local config 와 global portfolio 가 project 를 다른 ID 로 등록 (`swayloop-commitlint-config` vs `swayloop-commitlint-config_aae273ade5`). 명령마다 한 쪽이 못 찾아서 워커 spawn 미도달.
- **Polling 0 project** — 데몬 떠도 자동 polling enable 안 됨 (`running.json: projects: []`).
- **Worktree leak** — project ID 변경 시 기존 worktree 가 "outside AO-managed" 로 인식, 수동 cleanup 강제.
- `agent-grok` plugin 빌드 깨짐 (`/tmp/ao-publish-stable/...` 경로 박힘).
- Schema 와 runtime 메시지 모순 (schema 는 `projects:` wrap required, runtime 은 "wrapped format degraded" 라고 함).
- 모든 명령에 4종 notifier 미설정 noise.

**결론**: 도구 자체는 잠재력 큼. v0.9, 출시 3-4개월 — production 도입 시기상조. **v1.0 stable 후 재평가**.

### 2. smtg-ai/claude-squad — 패턴 미스매치

**모델**: 사람용 TUI 매니저. 풀스크린 키보드 UI 에서 인스턴스 만들고 attach 하며 짝코딩.

**장점**

- **v1.0.17 안정화 완료** (AO 와 결정적 차이)
- 7.6k stars, Go 단일 바이너리
- tmux + git worktree (workmux 와 동일 토대)
- Claude / Codex / Aider / Gemini / OpenCode / Amp 멀티 에이전트

**문제**

- **TUI 전용** — CLI 명령은 `version`, `debug`, `reset` 뿐. 에이전트가 인스턴스 자동 spawn 불가능
- 슬래시 커맨드 / sub-agent layer 얹기 어색 — 사람이 키보드로 인스턴스 관리하는 도구지, **자동화 backbone 아님**

**결론**: 일상 짝코딩 매니저로 매력적이지만, swayloop 가 추구하는 "에이전트가 자체 도구 호출하는 자동화 layer" 와 패턴 충돌.

### 3. raine/workmux — 채택

**모델**: 얇은 tmux + git worktree 헬퍼. CLI 명령으로 worktree 추가/제거.

**장점**

- **CLI 명령 있음** — Claude Code 가 `workmux add`, `workmux rm` 등 직접 호출 가능. 슬래시 커맨드 / sub-agent layer 자연스럽게 얹힘
- tmux session 직접 attach → 짝코딩 자연스러움
- 글로벌 config 이미 셋팅 완료 (`~/.config/workmux/config.yaml`)
- 얇은 도구 — swayloop 컨벤션 추가 안 막음, 자체 TUI 강요 안 함
- 활발한 개발 (1,907 commits), Rust 단일 바이너리, MIT
- Claude/Codex/Gemini/OpenCode built-in 지원

**단점**

- v0.1.x (1.0 미달, breaking change 가능)
- Stars 1.5k — claude-squad 의 1/5

## 결정 근거

swayloop 현재 단계 = 멀티 에이전트 워크플로우 표준화 + 자동화 layer 구축.

- **AO 같은 풀스택은 v1.0 까지 보류**. 그 동안 작업은 멈출 수 없음.
- **claude-squad 는 자동화 안 됨** — 슬래시 커맨드로 호출하는 패턴 자체가 불가.
- **workmux 는 CLI 가 있어서 에이전트가 직접 부르는 도구로 적합**.

자체 워크트리 관리 에이전트 (Claude Code 슬래시 커맨드 / sub-agent) 위에 workmux 를 깔면, AO 의 핵심 가치 (자동 워커 spawn) 를 swayloop 컨벤션에 맞춰 가볍게 재구현 가능하다.

## 결정 효과

### 즉시

- workmux 를 메인 오케스트레이션으로 표준화
- AO / claude-squad 는 글로벌 설치 정리 또는 secondary 도구로 보관

### 향후 작업

- `~/.claude/commands/worktree.md` 등 슬래시 커맨드로 workmux 자동화 layer 구축
- `agent_task.yml` 이슈 템플릿 (이슈 #2) → 슬래시 커맨드 입력 포맷
- swayloop 표준 (`<type>/<issue#>-<desc>` 브랜치 명명, Conventional Commits) 을 workmux config 와 슬래시 커맨드에 박기

## 재평가 트리거

다음 중 하나라도 발생 시 이 결정 재검토:

1. `@aoagents/ao` v1.0 stable 출시 + 위 Critical 3건 (ID mismatch, polling, worktree leak) fix 확인
2. workmux 가 v1.0 도달 못 한 채 6개월 이상 침묵 (`raine/workmux` 활동 중단)
3. swayloop 작업 패턴이 짝코딩 → 자율 워커 (fire-and-forget) 로 본격 전환
4. 멀티 repo / 멀티 contributor 운영으로 확장되어 dashboard / observability 필수 요구 발생

## 검증 여정 요약

```
2026-05-22  workmux 글로벌 config 셋업, 짝코딩 도구로 잠정 채택
2026-05-23  AO 가 풀스택 자율 워커 제공 — 채택 검토
2026-05-23  AO dogfooding (v0.9.1): project ID mismatch 외 마찰로 워커 spawn 미도달 → 보류
2026-05-23  claude-squad 검증: v1.0.17 안정적이지만 TUI-only, 자동화 layer 안 됨
2026-05-23  결론: workmux + 자체 워크트리 관리 슬래시 커맨드 = 가장 맞음
```

## 관련 이슈 / 문서

- 이슈 [#3](https://github.com/swayloop/.github/issues/3) — workmux 표준 셋업 (이 문서가 결과물)
- 이슈 [#2](https://github.com/swayloop/.github/issues/2) — 에이전트 친화적 이슈 템플릿 (슬래시 커맨드 입력 포맷)
- 이슈 [#4](https://github.com/swayloop/.github/issues/4) — Tooling Foundation (이 결정과 직교)
- [docs/workflow.md](./workflow.md) — 브랜치 / 커밋 컨벤션
