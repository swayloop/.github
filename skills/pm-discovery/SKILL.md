---
name: pm-discovery
description: 프로젝트 컨텍스트를 읽고 가설·검증할 최소 기능을 정해 create-issue 로 이슈를 만드는 PM 디스커버리(뭘 만들지 정하기) 루틴을 시작할 때 사용한다.
allowed-tools: Bash, Read, Write
---

# pm-discovery

프로젝트 맥락을 이해한 상태에서 **가설을 정하고, 그걸 검증할 최소 기능을 이슈로 만드는** PM 루틴.

## 컨텍스트 (먼저 읽는다)

이 스킬 안의 **`references/project-context.md`** 가 프로젝트 정본이자 **위키 라우터**다(스킬과 함께 배포·이동). 매 실행 시작에 읽고, 필요하면 거기서 링크된 위키 문서를 따라간다(progressive disclosure).

## 루틴 (이 순서로 진행)

1. **맥락 로드** — `references/project-context.md` 읽고 프로젝트를 파악한다.
2. **가설 설정** — 검증할 가정 1개를 *제안하고 사용자와 합의*한다. (예: "X 하면 Y 지표가 오른다")
3. **기능 결정** — 그 가설을 검증할 **최소 기능**을 정하고 우선순위를 매긴다. 크게 벌이지 않는다(가설 1개 = 작은 실험 1개).
4. **이슈 생성** — 결정된 작업을 **`create-issue` 스킬로 만든다** 이슈엔 가설과 성공지표를 명시한다.

## 어떻게 (필요한 문서로 이동)

- 한 바퀴 구체 예시 → `references/example.md`
- 이슈 생성 세부는 `create-issue` 스킬에 위임 (그 스킬의 SKILL.md 참조)
