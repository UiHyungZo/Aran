# AGENTS.md

## 프로젝트 개요

Aran은 시험관 시술(IVF) 관리용 iOS 앱입니다.

- 아키텍처: Clean Architecture + MVVM
- 언어: Swift 6
- 최소 타겟: iOS 17+
- 데이터 저장: SwiftData
- UI 구성
  - 캘린더 / 약 정보: SwiftUI + Combine
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
- `docs/decisions.md`
- `docs/roadmap.md`
- `docs/git-convention.md`

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

- 캘린더 / 약 정보 탭은 SwiftUI + Combine 사용
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
- `SearchDrugUseCase`
- `HealthRecordUseCase`

외부 의존성은 Mock으로 테스트합니다.

---

## MVP 우선순위

명시적으로 요청되지 않은 경우
Phase 2 기능은 구현하지 않습니다.

### 1순위 기능

- 월간 캘린더 메인 화면
- 날짜 상세 바텀시트
- 채취 / 이식 기록 입력
- 감정 일기 섹션 표시
- 약 목록
- 약 등록 폼
- UserNotifications 기반 알림
- DrugSearch 공통 컴포넌트
- e약은요 API 연동
- 검사 수치 입력 및 목록
- 최신 수치 / 증감 표시
- UseCase Unit Test
- README / GIF / GitHub 포트폴리오 정리

### 현재 제외 또는 Phase 2 기능

- 생리 주기 입력
- 배란일 자동 계산
- PGT / 염색체 / 반착검사
- Swift Charts 그래프
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
