# Project Standards

> 🚧 설계 중. 새 레포를 만들 때 따라야 할 공통 표준.

## 레포 생성 체크리스트

- [ ] 레포 이름은 kebab-case (예: `ui-agent`, `swayloop-blog`)
- [ ] 설명(description) 한 줄 작성
- [ ] `README.md` — 무엇/왜/어떻게 시작
- [ ] `LICENSE` — 공개 레포는 MIT 기본 ([템플릿](https://github.com/swayloop/.github/blob/main/LICENSE))
- [ ] `.gitignore` — 언어/프레임워크 표준
- [ ] 기본 브랜치는 `main`
- [ ] 브랜치 보호 (TODO: 규칙 확정)
- [ ] 이슈/PR 템플릿은 org `.github` 에서 상속됨 — 별도 설정 불필요
- [ ] CI 추가: Node/pnpm 레포는 `swayloop/.github/.github/workflows/node-pnpm-ci.yml@main` 호출

## README 구조

최소 다음 섹션을 포함:

1. 한 줄 설명
2. Why (왜 이 프로젝트가 존재하는가)
3. Quick start (5분 안에 돌려보기)
4. 주요 명령어 / 스크립트
5. 디렉토리 구조 (큰 그림)
6. Contributing (org `CONTRIBUTING.md` 링크)
7. License

## 디렉토리/파일 컨벤션

> TODO: 언어별로 다름. 공통으로 정할 수 있는 것만 추림.

- 시크릿/환경변수는 `.env.example` 만 커밋, `.env` 는 `.gitignore`
- 큰 바이너리는 Git LFS 또는 외부 스토리지
- 생성물(빌드 결과, 캐시) 은 커밋 금지

## 코드 품질 도구

> TODO: 언어별로 표준 도구 정리.

- JavaScript/TypeScript: ESLint + Prettier, CI 에서 `format:check` / `lint` / `typecheck` / `build` / `test` 조건부 실행
- Python: Ruff + Black or just Ruff(format)
- Go: gofmt + golangci-lint

## 결정해야 할 것 (TODO)

- [x] ~~기본 라이센스~~ → **MIT** (확정)
- [ ] 시크릿 스캐닝 / Dependabot 정책
- [ ] 보안 정책: 모든 레포가 `SECURITY.md` 상속받음 (org `.github` 통해) — 확인
- [ ] AI 어시스턴트 사용 가이드 (Claude Code / Cursor / Codex 등)
