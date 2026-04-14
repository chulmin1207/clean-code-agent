# Clean Code Agent

Claude Code에서 사용하는 클린코드 분석 에이전트.

분석만 하는 게 아니라 **측정하고, 실행하고, 증명**한다.

## 기존 클린코드 도구와의 차이

| | ESLint/Prettier | 기존 AI 리뷰 | **Clean Code Agent** |
|---|---|---|---|
| 규칙 기반 검사 | O | O | O |
| 의미 기반 분석 (SRP, 명명 의도) | X | O | O |
| 정량 점수 (루브릭) | X | 느낌 점수 | **측정 기반 점수** |
| 리팩토링 실행 | X | 제안만 | **직접 수정** |
| 실행 검증 (tsc, test) | X | X | **자동 실행 비교** |
| 아키텍처 분석 | X | X | **순환 의존, 레이어, 결합도** |

## 설치

```bash
git clone https://github.com/chulmin1207/clean-code-agent.git /tmp/cca
bash /tmp/cca/install.sh /path/to/your-project
```

## 커맨드

| 명령 | 설명 |
|------|------|
| `/clean` | 현재 git diff 변경사항 클린코드 검사 |
| `/review <파일\|디렉토리>` | 전면 리뷰 + 정량 점수 |
| `/refactor <파일>` | 리팩토링 + 실행 검증 (tsc, test, lint) |
| `/architect <디렉토리>` | 아키텍처 분석 (순환 의존, 레이어, 결합도, God 파일) |

## 동작 방식

### /review — 정량 측정 기반 점수

감점 항목을 **도구로 측정**한다. 느낌이 아니라 수치.

```
[가독성 & 명명] -3: proc (line 14) — 의도 불명확
[함수 설계] -5: proc (line 14-52, 38줄) — 20줄 초과
[함수 설계] -8: proc (line 14) — 이메일+DB+알림+포맷 4가지 책임
[중복] -5: proc/proc2 (line 14-52, 54-84) — 90% 동일 코드
...
총점: 18/100
```

### /refactor — 실행으로 동작 보장

```
## 실행 검증 결과
| 항목 | Before | After | 판정 |
|------|--------|-------|------|
| 타입 체크 | ✓ 0 errors | ✓ 0 errors | PASS |
| 테스트 | 42 pass / 0 fail | 42 pass / 0 fail | PASS |
| 린트 | 3 warnings | 1 warning | PASS (개선) |

검증 판정: VERIFIED
```

테스트가 깨지면 **자동 롤백** 후 원인 분석.
도구가 없는 환경이면 분기 나열로 **동등성 증명**.

### /architect — 프로젝트 구조 진단

```
## 아키텍처 분석: src/

순환 의존성: auth → user → permission → auth
레이어 위반: repositories/user.ts:3 → import from routes/index (L3→L1)
God 파일: services/payment.ts (482줄, 15 exports)
결합도 경고: utils/index.ts (fan-in: 23)

아키텍처 점수: 4/10
```

## 점수 루브릭

### 함수/파일 단위 (90점)

| 관점 | 배점 | 감점 기준 |
|------|------|-----------|
| 가독성 & 명명 | 20 | 1-2글자 이름 -3/개, 컨벤션 불일치 -5 |
| 함수 설계 | 20 | 20줄 초과 -5/개, SRP 위반 -8/개, 매개변수 초과 -3/개 |
| 중복 | 20 | 유사도 70%+ 블록 -5/개 |
| 복잡도 | 20 | 중첩 3단계+ -5/개, 부정 조건 -2/개 |
| 주석 | 10 | 코드 설명 주석 -2/개, 거짓 주석 -5/개 |

**총점 = 함수/파일 점수(90점) + 아키텍처 점수(10점) = 100점**

### 아키텍처 단위 (10점)

| 관점 | 감점 |
|------|------|
| 순환 의존 | -3/개 |
| 레이어 역전 | -2/개 |
| God 파일 | -1/개 |

## 심각도

| 등급 | 기준 |
|------|------|
| **CRITICAL** | 순환 의존성, 레이어 위반, 보안 취약점 |
| **HIGH** | SRP 위반, 테스트 불가 구조, God 파일 |
| **MED** | 가독성 저해, DRY 위반, 온보딩 지연 |
| **LOW** | 컨벤션 불일치, 더 나은 이름, 미세 구조 개선 |

## 지원 언어 & 도구

| 언어 | 타입 체크 | 린트 | 테스트 |
|------|-----------|------|--------|
| TypeScript | tsc --noEmit | eslint | npm test |
| JavaScript | - | eslint | npm test |
| Python | mypy | ruff | pytest |
| Go | go vet | golangci-lint | go test |
| Rust | cargo check | cargo clippy | cargo test |

## 구조

```
your-project/
├── CLAUDE.md                    ← 원칙, 루브릭, 검증 프로토콜
├── AGENTS.md                    ← CLAUDE.md 심볼릭 링크 (Codex용)
└── .claude/
    ├── settings.json            ← 권한 (5개 언어 도구 허용)
    ├── agents/
    │   └── clean-code.md        ← 분석+검증+아키텍처 에이전트
    └── commands/
        ├── clean.md             ← /clean
        ├── review.md            ← /review
        ├── refactor.md          ← /refactor (실행 검증 포함)
        └── architect.md         ← /architect
```

## 커스터마이징

- **루브릭 변경**: CLAUDE.md와 agents/clean-code.md의 점수 테이블 수정
- **레이어 정의 변경**: agents/clean-code.md의 레이어 매핑 수정
- **God 파일 기준 변경**: 300줄 → 원하는 수치로 수정
- **언어 도구 추가**: settings.json의 allow에 해당 명령 추가

## GitHub Actions

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
      - name: Architecture Check
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          claude -p "src/ 디렉토리 아키텍처 분석하고 arch-report.md로 저장"
      - name: Comment on PR
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            let body = '## Clean Code Review\n\n';
            if (fs.existsSync('clean-code-report.md'))
              body += fs.readFileSync('clean-code-report.md', 'utf8');
            if (fs.existsSync('arch-report.md'))
              body += '\n\n---\n\n## Architecture\n\n' + fs.readFileSync('arch-report.md', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body
            });
```

## 라이선스

MIT
