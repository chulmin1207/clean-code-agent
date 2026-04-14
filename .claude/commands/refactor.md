$ARGUMENTS 에 지정된 파일을 클린코드 원칙에 따라 리팩토링하세요.

## 전제 조건

- $ARGUMENTS 가 없으면: "리팩토링 대상 파일을 지정해주세요. 예: /refactor src/utils/validator.ts" 출력 후 종료
- 대상 파일이 존재하지 않으면: 에러 출력 후 종료

## 규칙

- 동작하는 로직은 절대 변경하지 말 것
- 리팩토링만 수행 (기능 추가 금지)
- 모든 변경의 이유를 diff와 함께 설명

## 실행 검증 (필수)

리팩토링 전후로 반드시 실행 검증을 수행한다:

### Before 스냅샷
1. 프로젝트 환경 감지 (tsconfig.json, package.json, pyproject.toml, go.mod, Cargo.toml)
2. 타입 체크 실행 (있으면): npx tsc --noEmit / mypy / go vet / cargo check
3. 린트 실행 (있으면): npx eslint / ruff check / cargo clippy
4. 테스트 실행 (있으면): npm test / pytest / go test / cargo test
5. 결과 저장

### 리팩토링 수행
1. 함수 분리 (20줄 초과)
2. 변수명/함수명 개선
3. 중복 코드 제거
4. 부정 조건 → 긍정 조건
5. Early Return 적용

### After 검증
1. 동일한 타입 체크, 린트, 테스트 재실행
2. 비교 판정:
   - 테스트 통과 수 감소 → 즉시 롤백, 원인 분석 후 재시도
   - 타입 에러 신규 발생 → 수정 후 재검증
   - 린트 에러 신규 발생 → 수정 후 재검증
3. 도구가 없는 환경이라도 리팩토링 전후 모든 분기를 나열하여 동등성을 증명

### 검증 리포트 (반드시 출력)
```
## 실행 검증 결과
| 항목 | Before | After | 판정 |
|------|--------|-------|------|
| 타입 체크 | ... | ... | PASS/FAIL |
| 테스트 | ... | ... | PASS/FAIL |
| 린트 | ... | ... | PASS/FAIL |

검증 판정: VERIFIED / FAILED
```

실행 검증 없이 "리팩토링 완료"라고 보고하지 말 것.
