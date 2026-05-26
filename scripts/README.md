# scripts

org 표준을 레포에 적용하는 유틸 스크립트.

## apply-rulesets.sh

main / dev 브랜치 보호 ruleset 을 레포에 적용 (멱등).

```bash
# 한 레포에만
./scripts/apply-rulesets.sh swayloop/my-repo

# 모든 public 레포에
./scripts/apply-rulesets.sh --all
```

**요구사항:** `gh` CLI 가 `admin:org` 또는 해당 레포 admin 권한으로 로그인되어 있어야 함.

**적용되는 보호 룰:**
- `main` (default branch): PR 강제, force push 금지, 삭제 금지, linear history, `pr-source-branch-check / check` status check 통과 필요
- `dev`: force push 금지, 삭제 금지

> `pr-source-branch-check / check` 는 [reusable workflow](../.github/workflows/pr-source-branch-check.yml) 가 생성하는 status check. 각 레포에 caller workflow 가 등록되어 있어야 통과 가능 (workflow 가 없으면 main 으로 머지 자체가 막힘).

## 신규 레포 부트스트랩 체크리스트

```bash
# 1. 레포 생성
gh repo create swayloop/my-app --public

# 2. template-node 로 부트스트랩
npx degit swayloop/template-node my-app
cd my-app
git init -b main && git add -A && git commit -m "chore: bootstrap from swayloop/template-node"

# 3. 푸시
git remote add origin git@github.com:swayloop/my-app.git
git push -u origin main
git checkout -b dev && git push -u origin dev

# 4. 보호 룰 적용
cd /path/to/swayloop-.github
./scripts/apply-rulesets.sh swayloop/my-app

# 5. (옵션) Claude 시크릿 설정
gh secret set CLAUDE_CODE_OAUTH_TOKEN -R swayloop/my-app
```
