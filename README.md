# Clean Code Agent

Claude Code / Codex CLI에서 사용하는 클린코드 분석 에이전트.

아무 프로젝트에나 설치해서 바로 쓸 수 있다.

## 설치

```bash
# 방법 1: 스크립트로 설치
git clone https://github.com/yourname/clean-code-agent.git /tmp/clean-code-agent
bash /tmp/clean-code-agent/install.sh /path/to/your-project

# 방법 2: 수동 복사
cp -r .claude/agents/ /path/to/your-project/.claude/agents/
cp -r .claude/commands/ /path/to/your-project/.claude/commands/
cp CLAUDE.md /path/to/your-project/CLAUDE.md
```

## 사용법

Claude Code 안에서:

```
/clean                    # 현재 변경사항 클린코드 검사
/review src/api/user.ts   # 특정 파일 리뷰
/review src/components/   # 디렉토리 전체 리뷰
/refactor src/utils.ts    # 자동 리팩토링
```

Codex CLI에서:

```bash
codex "현재 변경 파일들을 클린코드 분석해줘"
```

CI/CD에서:

```bash
claude -p "git diff origin/main...HEAD 를 클린코드 분석하고 report.md로 저장해줘"
```

## 구조

```
your-project/
├── CLAUDE.md                    ← 원칙, 체크리스트, 루브릭
├── AGENTS.md                    ← CLAUDE.md 심볼릭 링크 (Codex용)
└── .claude/
    ├── settings.json            ← 권한 (안전한 명령만 허용)
    ├── agents/
    │   └── clean-code.md        ← 분석 에이전트 정의
    └── commands/
        ├── clean.md             ← /clean
        ├── review.md            ← /review
        └── refactor.md          ← /refactor
```

## 분석 관점 (5가지)

| # | 관점 | 배점 | 체크 항목 |
|---|------|------|-----------|
| 1 | 가독성 & 명명 | 25점 | 이름이 의도를 드러내는가, 컨벤션 일관성 |
| 2 | 함수 설계 | 25점 | 20줄 초과, 매개변수 3개 초과, SRP 위반 |
| 3 | 중복 | 20점 | DRY 위반, 유사 코드 블록 |
| 4 | 복잡도 | 20점 | 중첩 3단계, 조건 분기, 부정 조건 |
| 5 | 주석 | 10점 | 코드 설명 주석, 거짓 주석 |

## 지원 언어

TypeScript/JavaScript, Python, Go, Java, Rust — 각 언어의 공식 네이밍 컨벤션 자동 적용.
기타 언어도 분석 가능 (해당 언어 스타일 가이드 기준).

## 커스터마이징

- **원칙 추가/변경**: `CLAUDE.md`의 "원칙" 섹션 수정
- **감점 기준 조정**: `CLAUDE.md`와 `.claude/agents/clean-code.md`의 루브릭 테이블 수정
- **권한 변경**: `.claude/settings.json`의 allow/deny 수정
- **언어별 린터 추가**: settings.json의 allow에 해당 린터 명령 추가

## GitHub Actions 연동

```yaml
name: Clean Code Review
on:
  pull_request:
    types: [opened, synchronize]
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Clean Code Review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          npm install -g @anthropic-ai/claude-code
          claude -p "git diff origin/main...HEAD 를 클린코드 분석하고 clean-code-report.md로 저장"
      - name: Comment on PR
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('clean-code-report.md', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## Clean Code Review\n\n${report}`
            });
```

## 라이선스

MIT
