# AGENTS.md

## ✨ AI 코딩 에이전트 행동 지침 (Karpathy Guidelines)

모든 LLM 기반 코딩 에이전트(Claude Code, Cursor 등)가 따라야 할 4가지 핵심 원칙.

### 1. 구현 전 사고 (Think Before Coding)

가정하지 않는다. 모호함을 숨기지 않는다. 트레이드오프를 명확히 밝힌다.

구현을 시작하기 전 다음을 준수한다:

- 자신의 가정을 명시적으로 기술한다. 불확실한 경우 질문한다.
- 해석의 여지가 여러 가지라면 임의로 선택하지 말고 대안들을 제시한다.
- 더 간단한 접근 방식이 있다면 제안한다. 정당한 사유가 있다면 사용자의 요청에 반대 의견을 제시한다.
- 불분명한 부분이 있다면 작업을 중단한다. 혼란스러운 부분을 구체적으로 언급하며 질문한다.

### 2. 단순성 우선 (Simplicity First)

- 문제를 해결하는 최소한의 코드만 작성한다. 추측에 기반한 코드는 배제한다.
- 요청되지 않은 기능은 추가하지 않는다.
- 일회성 코드를 위해 추상화 계층을 만들지 않는다.
- 요청되지 않은 유연성이나 설정 가능성을 고려하지 않는다.
- 발생 불가능한 시나리오에 대한 예외 처리를 하지 않는다.
- 200줄의 코드를 50줄로 줄일 수 있다면 코드를 다시 작성한다.
- "시니어 엔지니어가 보기에 이 코드가 지나치게 복잡한가?"라고 자문한다. 그렇다면 단순화한다.

### 3. 정밀한 수정 (Surgical Changes)

필요한 부분만 수정한다. 본인이 만든 코드의 뒷정리만 수행한다.

기존 코드를 편집할 때 다음을 준수한다:

- 인접한 코드, 주석, 포맷을 임의로 개선하지 않는다.
- 망가지지 않은 부분을 리팩토링하지 않는다.
- 본인의 스타일과 다르더라도 기존 스타일을 따른다.
- 작업과 무관한 데드 코드를 발견하면 보고하되 직접 삭제하지 않는다.

수정으로 인해 사용되지 않게 된 요소가 발생할 경우:

- 본인의 수정으로 인해 불필요해진 임포트, 변수, 함수는 제거한다.
- 기존에 존재하던 데드 코드는 요청이 없는 한 그대로 둔다.
- 테스트 기준: 변경된 모든 라인은 사용자의 요청사항과 직접적으로 연결되어야 한다.

### 4. 목표 중심 실행 (Goal-Driven Execution)

성공 기준을 정의한다. 검증될 때까지 반복한다.

작업을 검증 가능한 목표로 변환한다:

- "유효성 검사 추가" → "잘못된 입력에 대한 테스트 작성 후 통과 확인"
- "버그 수정" → "버그를 재현하는 테스트 작성 후 통과 확인"
- "X 리팩토링" → "리팩토링 전후의 테스트 통과 확인"

다단계 작업의 경우 간략한 계획을 수립한다:

1. [단계] → 검증: [확인 사항]
2. [단계] → 검증: [확인 사항]
3. [단계] → 검증: [확인 사항]

성공 기준이 명확해야 독립적인 작업이 가능하다. "작동하게 만들기"와 같은 모호한 기준은 불필요한 재질의를 야기한다.

---

## 프로젝트 개요

Aran은 시험관 시술(IVF) 관리용 iOS 앱입니다.

- 아키텍처: Clean Architecture + MVVM
- 언어: Swift 6
- 최소 타겟: iOS 17+
- 데이터 저장: SwiftData
- UI 구성
  - 캘린더 / 시술 기록 / 약 정보: SwiftUI + Combine
  - 약/주사 / 검사: UIKit + RxSwift
- 테스트 전략: UseCase Unit Test 우선

---

## 문서 우선 확인

큰 변경 작업 전에 아래 문서를 먼저 참고합니다.

- `docs/architecture.md`
- `docs/features.md`
- `docs/api.md`
- `docs/coding-style.md`
- `docs/testing.md`
- `docs/concurrency.md`
- `docs/data-model.md`
- `docs/roadmap.md`
- `docs/ADR.md`
- `docs/git-convention.md`
- `docs/UI_GUIDE.md`

---

## 아키텍처 규칙

- Clean Architecture 계층을 반드시 유지합니다.
- Domain Layer는 아래 프레임워크를 import하면 안 됩니다.
  - UIKit
  - SwiftUI
  - RxSwift
  - Combine
  - SwiftData
  - Alamofire
  - UserNotifications
- Presentation은 Domain에만 의존합니다.
- Data Layer는 Domain의 Repository Protocol을 구현합니다.
- 비즈니스 로직은 ViewController / View 내부에 작성하지 않습니다.
- UseCase는 Mock 기반 테스트 가능 구조로 유지합니다.

---

## UI 규칙

- 캘린더 / 시술 기록 / 약 정보 탭은 SwiftUI + Combine 사용
- 약/주사 / 검사 탭은 UIKit + RxSwift 사용
- UIKit ↔ SwiftUI 브릿지는 UIHostingController 사용
- ViewModel은 상태 관리와 액션 처리 담당
- View / ViewController는 렌더링과 바인딩 중심으로 유지

---

## SwiftData 규칙

- 로컬 저장은 SwiftData 사용
- Persistence 로직은 Data Layer 내부에만 작성
- SwiftData 타입을 Domain Layer로 노출하지 않음

---

## RxSwift / Combine 규칙

- RxSwift는 UIKit 기반 기능에서만 사용
- Combine은 SwiftUI 기반 기능에서만 사용
- UI 관련 ViewModel에는 필요 시 @MainActor 적용
- RxSwift 연동 시 필요한 경우에만
  `@preconcurrency import RxSwift`
  `@preconcurrency import RxCocoa`
  사용

---

## 테스트 규칙

UseCase Unit Test를 우선 작성합니다.

필수 테스트 대상:

- `CycleRecordUseCase`
- `MedicationNotificationUseCase`
- `MedicationLogUseCase`
- `MenstrualCycleUseCase`
- `SearchDrugUseCase`
- `HealthRecordUseCase`

외부 의존성은 Mock으로 테스트합니다.

---

## MVP 우선순위

명시적으로 요청되지 않은 경우 Phase 2 기능은 구현하지 않습니다.

### 1순위 기능

- 월간 캘린더 메인 화면
- 날짜 2단계 바텀시트 (전체 섹션)
- 복용 약 체크 (MedicationLog)
- 병원 일정 복수 종류 선택
- 생리 주기 입력 + 배란일 자동 계산
- 감정 일기 입력/수정/삭제
- 채취 / 이식 기록 입력
- PGT / 염색체 / 반착검사 기록
- 시술 기록 탭 Presentation 전체
- 약 목록 / 약 등록 폼 / 수정 화면
- UserNotifications 기반 알림
- DrugSearch 공통 컴포넌트
- e약은요 API 연동
- 검사 수치 입력 / 목록 / 수정/삭제
- 최신 수치 / 증감 TrendBadge
- UseCase Unit Test
- README / GIF / GitHub 포트폴리오 정리

### 현재 제외 또는 Phase 2 기능

- Swift Charts 그래프 (검사 탭 / 시술 기록 탭)
- HealthKit
- 전체 UI Test
- Firebase
- Bluetooth
- iPad 대응
- 앱스토어 배포

---

## 빌드 및 검증 규칙

코드 변경 후:

- 프로젝트 빌드 확인
- UseCase 변경 시 관련 테스트 실행
- 빌드 / 테스트 실패 시 원인 명확히 설명
- 경고나 에러를 숨기지 않음
- 관련 없는 리팩토링 최소화

---

## Git 규칙

- 작은 단위로 명확하게 커밋
- 포트폴리오용으로 읽기 좋은 커밋 메시지 작성
- 아래 prefix 사용 권장
  - `feat:`
  - `fix:`
  - `refactor:`
  - `test:`
  - `docs:`
  - `chore:`

---

## 작업 행동 규칙

- 큰 구조 변경 전 반드시 먼저 제안
- 새로운 라이브러리 추가 전 승인 요청
- 프로젝트 범위를 임의로 변경하지 않음
- 과한 추상화보다 유지보수성을 우선
- 현재 MVP 문서 기준으로 구현 유지
