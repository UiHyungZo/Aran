# /review

현재 변경사항을 프로젝트 규칙 기준으로 리뷰한다.

## 리뷰 대상
1. `git diff --stat`
2. `git diff`
3. 변경된 Swift 파일
4. 변경된 테스트 파일
5. 관련 docs 규칙

## 필수 확인 문서
- `CLAUDE.md`
- `docs/architecture.md`
- `docs/coding-style.md`
- `docs/testing.md`
- 필요 시 `docs/api.md`, `docs/UI_GUIDE.md`, `docs/ADR.md`

## 리뷰 기준
- Clean Architecture 의존성 방향 준수 여부
- ViewController/View 내부 비즈니스 로직 여부
- ViewModel → UseCase → Repository 흐름 준수 여부
- DTO와 Domain Entity 분리 여부
- UIKit Feature의 RxSwift 규칙 준수 여부
- SwiftUI Feature의 Combine 규칙 준수 여부
- API Key/Secret 하드코딩 여부
- 테스트 추가 또는 수정 필요 여부
- 과도한 추상화 여부

## 출력 형식
### 🔴 Critical
반드시 수정해야 하는 항목

### 🟡 Warning
수정 권장 항목

### 🟢 Suggestion
개선 고려 항목

### ✅ Good
잘 지킨 항목

### 다음 액션
가장 작은 수정 단위로 제안한다.
