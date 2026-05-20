# Decisions

## Goal

이 문서는 Aran 프로젝트의 주요 기술 선택과 설계 의사결정을 기록한다.

목표:

* 왜 이 구조를 선택했는지 설명 가능하게 만든다.
* 포트폴리오 면접에서 기술 선택 근거를 제시한다.
* 향후 변경 시 기존 결정의 배경을 추적할 수 있게 한다.
* 불필요한 기술 확장을 방지한다.

이 문서는 ADR처럼 사용하되, 과하게 형식화하지 않는다.

---

# Decision Format

각 결정은 다음 형식으로 기록한다.

```text
## Decision: 제목

Status:
- Accepted / Deferred / Rejected

Context:
- 문제 상황

Decision:
- 선택한 방향

Reason:
- 선택 이유

Trade-off:
- 감수한 단점
```

---

# Decision 1: Clean Architecture + MVVM 사용

Status:

* Accepted

Context:

* IVF 앱은 일정, 약, 검사, 알림, API 검색 등 여러 기능이 연결된다.
* UI, DB, 네트워크, 알림 로직이 섞이면 테스트와 유지보수가 어려워진다.
* 포트폴리오에서 구조적 사고를 보여줄 필요가 있다.

Decision:

* Clean Architecture + MVVM을 사용한다.
* Domain, Data, Presentation, Infrastructure 계층을 분리한다.
* ViewModel은 UseCase를 통해서만 비즈니스 로직을 실행한다.

Reason:

* Domain 로직을 UI/DB/Network와 분리할 수 있다.
* UseCase 단위 테스트가 가능하다.
* Repository Protocol 기반으로 Mock 교체가 쉽다.
* 면접에서 의존성 방향을 명확히 설명할 수 있다.

Trade-off:

* 파일 수가 증가한다.
* 작은 기능에도 boilerplate가 생길 수 있다.
* 과도한 추상화를 피하기 위해 사용 사례가 1개뿐인 abstraction은 지양한다.

---

# Decision 2: UIKit + RxSwift와 SwiftUI + Combine 혼합

Status:

* Accepted

Context:

* 앱에는 서로 성격이 다른 화면이 존재한다.
* 캘린더와 약 정보 화면은 상태 기반 UI에 적합하다.
* 약/주사, 검사 화면은 UITableView, 입력 폼, swipe action 등 UIKit 제어가 유리하다.

Decision:

* Calendar와 DrugInfo는 SwiftUI + Combine으로 구현한다.
* Medication / Injection과 HealthRecord는 UIKit + RxSwift로 구현한다.
* Feature 내부에서는 reactive stack을 혼합하지 않는다.

Reason:

* SwiftUI는 상태 기반 UI와 빠른 화면 구성에 적합하다.
* UIKit은 복잡한 리스트, 입력 폼, swipe action 제어에 안정적이다.
* RxSwift는 UIKit 이벤트 바인딩과 ViewModel 구조화에 적합하다.
* Combine은 SwiftUI 상태 관리와 자연스럽게 연결된다.

Trade-off:

* 두 reactive stack을 관리해야 한다.
* 브리징 지점이 필요하다.
* 혼합 구조가 복잡해질 수 있으므로 feature 단위 경계를 강하게 유지한다.

---

# Decision 3: Feature 내부 Reactive Stack 혼합 금지

Status:

* Accepted

Context:

* RxSwift와 Combine을 같은 feature 내부에서 섞으면 흐름 추적이 어려워진다.
* Observable, Publisher, Driver 간 변환이 늘어나면 코드 복잡도가 증가한다.

Decision:

* SwiftUI feature는 Combine만 사용한다.
* UIKit feature는 RxSwift만 사용한다.
* 브리징은 UIHostingController 또는 UIViewRepresentable처럼 명확한 경계에서만 허용한다.

Reason:

* 상태 흐름을 단순하게 유지할 수 있다.
* 디버깅이 쉬워진다.
* 면접에서 기술 선택 경계를 설명하기 쉽다.

Trade-off:

* 일부 데이터 흐름에서 변환 코드가 필요할 수 있다.
* 공통 컴포넌트 재사용 시 mode 설계가 필요하다.

---

# Decision 4: DrugSearchView 재사용

Status:

* Accepted

Context:

* 약 정보 탭에서는 약을 검색하고 상세 정보를 본다.
* 약/주사 탭에서는 약을 검색한 뒤 등록 폼에 자동 입력해야 한다.
* 두 화면 모두 같은 e약은요 API 검색 로직을 사용한다.

Decision:

* DrugSearchView를 `browse` / `register` mode로 재사용한다.

```swift
enum DrugSearchMode {
    case browse
    case register
}
```

Reason:

* 검색 UI와 API 로직 중복을 줄일 수 있다.
* SearchDrugUseCase를 공유할 수 있다.
* register mode에서는 선택 결과를 MedicationForm으로 전달할 수 있다.

Trade-off:

* View가 mode에 따라 분기한다.
* mode 분기가 과도해지면 별도 Coordinator 또는 구성 객체로 분리할 수 있다.

---

# Decision 5: UIHostingController 브리징 사용

Status:

* Accepted

Context:

* DrugSearchView는 SwiftUI + Combine으로 구현된다.
* Medication flow는 UIKit + RxSwift 기반이다.
* Medication 등록 과정에서 SwiftUI 검색 화면을 재사용해야 한다.

Decision:

* UIKit flow에서 DrugSearchView를 사용할 때 UIHostingController를 사용한다.

Flow:

```text
MedicationViewController
→ UIHostingController
→ DrugSearchView(mode: .register)
→ MedicationFormViewController
```

Reason:

* DrugSearch UI를 중복 구현하지 않아도 된다.
* SwiftUI와 UIKit 경계를 명확히 유지할 수 있다.
* 브리징 이유가 분명하다.

Trade-off:

* 데이터 전달 방식 설계가 필요하다.
* SwiftUI/ UIKit lifecycle 차이를 고려해야 한다.

---

# Decision 6: SwiftData 사용

Status:

* Accepted

Context:

* 앱의 핵심 데이터는 로컬 중심이다.
* 약, 일정, 검사 기록, 감정 기록은 사용자의 개인 데이터다.
* MVP에서는 서버 동기화가 필요하지 않다.

Decision:

* 로컬 저장소로 SwiftData를 사용한다.

Reason:

* iOS 17+ 타겟과 잘 맞는다.
* Swift 기반 모델링이 가능하다.
* 포트폴리오에서 최신 Apple persistence 기술을 설명할 수 있다.
* CoreData보다 초기 구현 부담이 낮다.

Trade-off:

* iOS 17 미만을 지원하지 않는다.
* SwiftData 성숙도와 제약을 고려해야 한다.
* 복잡한 sync나 migration은 MVP에서 제외한다.

---

# Decision 7: SwiftData Model과 Domain Entity 분리

Status:

* Accepted

Context:

* SwiftData `@Model` 타입을 Domain까지 노출하면 Domain이 persistence에 의존하게 된다.
* 테스트 시 SwiftData 환경이 필요해질 수 있다.

Decision:

* SwiftData Model과 Domain Entity를 분리한다.
* Mapper를 통해 변환한다.

Flow:

```text
SwiftData Model
→ Mapper
→ Domain Entity
```

Reason:

* Domain을 순수 Swift로 유지할 수 있다.
* UseCase 테스트가 쉬워진다.
* persistence 변경에 대한 영향 범위를 줄일 수 있다.

Trade-off:

* Mapper 코드가 필요하다.
* 모델 변경 시 Mapper도 함께 수정해야 한다.

---

# Decision 8: MedicationSchedule 분리

Status:

* Accepted

Context:

* 하나의 약은 여러 복용 시간을 가질 수 있다.
* 각 복용 시간마다 알림 ID와 ON/OFF 상태가 다르다.

Decision:

* Medication과 MedicationSchedule을 분리한다.

Relationship:

```text
Medication
1:N
MedicationSchedule
```

Reason:

* 시간별 알림 관리가 가능하다.
* 복용 시간 수정 시 특정 schedule만 변경할 수 있다.
* notificationId를 안정적으로 관리할 수 있다.
* 면접에서 데이터 모델링 근거를 설명하기 좋다.

Trade-off:

* 모델 관계가 조금 복잡해진다.
* 저장/삭제 시 cascade 정책을 신경 써야 한다.

---

# Decision 9: e약은요 API 사용

Status:

* Accepted

Context:

* 약 검색과 약 상세 정보는 직접 데이터를 구축하기 어렵다.
* 공공 API를 활용하면 실제 서비스에 가까운 네트워크 흐름을 구현할 수 있다.

Decision:

* 식품의약품안전처 e약은요 OpenAPI를 사용한다.

Reason:

* 약 이름 검색과 상세 조회가 가능하다.
* Router, DTO, Repository, Mapper 구조를 보여주기 좋다.
* 실제 API 기반 fallback UX를 설계할 수 있다.

Trade-off:

* IVF 전문 약물이 검색되지 않을 수 있다.
* API 응답 품질과 필드 누락에 대비해야 한다.
* 직접 입력 fallback이 필수다.

---

# Decision 10: Empty Result를 Error로 보지 않음

Status:

* Accepted

Context:

* IVF 관련 약물이나 주사는 e약은요 API에서 검색되지 않을 수 있다.
* 검색 결과 없음은 시스템 실패가 아니라 예상 가능한 UX 상황이다.

Decision:

* Empty Result는 error가 아니라 empty state로 처리한다.
* register mode에서는 직접 입력 fallback을 제공한다.

Reason:

* 사용자 흐름이 끊기지 않는다.
* 실제 도메인 상황에 맞는 UX다.
* API 한계를 제품적으로 보완할 수 있다.

Trade-off:

* UI 상태가 loading / empty / error / success로 세분화된다.
* ViewModel 상태 관리가 조금 복잡해진다.

---

# Decision 11: UserNotifications를 Schedule 단위로 관리

Status:

* Accepted

Context:

* 복용 약 하나에 여러 복용 시간이 있을 수 있다.
* 각 시간마다 알림 ON/OFF 상태가 다를 수 있다.

Decision:

* notificationId는 MedicationSchedule 단위로 관리한다.
* 알림 수정 시 기존 알림을 취소하고 새 알림을 등록한다.

Reason:

* 특정 시간 알림만 수정 가능하다.
* 복용 시간별 ON/OFF가 가능하다.
* 알림과 데이터 모델의 매핑이 명확하다.

Trade-off:

* schedule 삭제 시 알림 삭제를 함께 처리해야 한다.
* notificationId 정합성을 유지해야 한다.

---

# Decision 12: UseCase 중심 TDD 적용

Status:

* Accepted

Context:

* 전체 앱을 TDD로 작성하면 4주 MVP 일정에 부담이 크다.
* 하지만 Clean Architecture의 장점을 보여주려면 테스트가 필요하다.

Decision:

* UseCase를 중심으로 TDD를 적용한다.
* UI는 일반 개발 후 핵심 흐름만 테스트한다.

Reason:

* Domain 로직 테스트 가능성을 증명할 수 있다.
* Mock Repository 기반 테스트가 가능하다.
* 포트폴리오에서 구조 선택 이유를 설명할 수 있다.

Trade-off:

* 전체 테스트 커버리지는 제한적일 수 있다.
* UI Test는 Phase 2로 이월될 수 있다.

---

# Decision 13: Firebase 미사용

Status:

* Rejected

Context:

* Firebase를 사용하면 인증, DB, 분석 기능을 빠르게 붙일 수 있다.
* 하지만 Aran MVP는 로컬 중심의 IVF 기록 앱이다.

Decision:

* MVP에서는 Firebase를 사용하지 않는다.

Reason:

* 개인 건강 정보 특성상 로컬 저장이 적합하다.
* 앱 핵심 가치와 직접 관련이 낮다.
* 구현 범위가 불필요하게 커진다.
* SwiftData 기반 로컬 구조를 보여주는 것이 포트폴리오에 더 적합하다.

Trade-off:

* 클라우드 동기화는 제공하지 않는다.
* 기기 변경 시 데이터 이전은 MVP 범위 밖이다.

---

# Decision 14: HealthKit 미사용

Status:

* Deferred

Context:

* HealthKit 연동은 건강 앱 포트폴리오에서 매력적인 요소다.
* 하지만 IVF 치료 기록과 직접 연결되는 핵심 MVP는 아니다.

Decision:

* HealthKit은 Phase 2로 이월한다.

Reason:

* 권한 처리와 데이터 매핑이 추가된다.
* 4주 MVP 범위를 초과한다.
* 현재 핵심은 일정, 약, 검사, 이식 기록이다.

Trade-off:

* Apple 생태계 연동 어필은 MVP에서 제한된다.
* Phase 2 확장 포인트로 남긴다.

---

# Decision 15: Swift Charts 미사용

Status:

* Deferred

Context:

* 검사 수치 변화는 차트로 보여주면 좋다.
* 하지만 MVP에서는 입력과 최신값/증감 표시가 우선이다.

Decision:

* Swift Charts는 Phase 2로 이월한다.
* MVP에서는 TrendBadge와 히스토리 목록으로 표현한다.

Reason:

* 구현 부담을 줄인다.
* 검사 기록의 핵심 흐름을 먼저 완성한다.
* 차트 없이도 수치 변화는 최신값/증감으로 표현 가능하다.

Trade-off:

* 시각적 완성도는 낮아질 수 있다.
* README/GIF에서 검사 탭 어필 요소가 제한될 수 있다.

---

# Decision 16: iPhone 우선 대응

Status:

* Accepted

Context:

* 포트폴리오 MVP는 제한된 기간 내 완성이 중요하다.
* iPad 대응은 layout complexity를 증가시킨다.

Decision:

* MVP에서는 iPhone 화면을 우선한다.
* iPad 대응은 Phase 2로 이월한다.

Reason:

* IVF 치료 관리 앱의 주 사용 맥락은 모바일이다.
* 구현 범위를 줄일 수 있다.
* 핵심 기능 완성에 집중할 수 있다.

Trade-off:

* iPad UX는 제공하지 않는다.
* adaptive layout 어필은 제한된다.

---

# Decision 17: App Store 배포 제외

Status:

* Rejected

Context:

* App Store 배포는 심사, 개인정보 처리, 정책 대응이 필요하다.
* 포트폴리오 목적에서는 GitHub와 시뮬레이터 데모만으로 충분하다.

Decision:

* MVP에서는 App Store 배포를 목표로 하지 않는다.
* GitHub README, GIF, 코드 구조를 제출물로 삼는다.

Reason:

* 개발 시간을 핵심 기능에 집중할 수 있다.
* 정책 대응 리스크를 줄일 수 있다.
* 포트폴리오 목적과 더 잘 맞는다.

Trade-off:

* 실제 사용자 배포 경험은 포함되지 않는다.
* TestFlight나 심사 경험은 어필하지 못한다.

---

# Decision 18: 과도한 추상화 지양

Status:

* Accepted

Context:

* Clean Architecture 프로젝트는 Protocol, Factory, Coordinator, Generic이 과하게 늘어날 수 있다.
* 포트폴리오에서는 복잡함보다 설명 가능성이 중요하다.

Decision:

* 사용 사례가 하나뿐인 abstraction은 만들지 않는다.
* 명확한 책임 분리와 읽기 쉬운 흐름을 우선한다.

Reason:

* 코드 리뷰와 면접 설명이 쉬워진다.
* 기능 구현 속도를 유지할 수 있다.
* 불필요한 boilerplate를 줄일 수 있다.

Trade-off:

* 일부 중복 코드가 허용될 수 있다.
* 나중에 재사용성이 필요해지면 그때 추상화한다.

---

# Decision 19: README + GIF를 최종 제출물로 사용

Status:

* Accepted

Context:

* 포트폴리오 프로젝트는 코드뿐 아니라 설명 자료가 중요하다.
* 면접관이 짧은 시간 안에 프로젝트 가치를 파악해야 한다.

Decision:

* README에 기능 설명, 아키텍처, 기술 선택 이유, 테스트 전략을 정리한다.
* 핵심 화면 흐름은 GIF로 제공한다.

Reason:

* 프로젝트 의도를 빠르게 전달할 수 있다.
* 실제 동작을 시각적으로 보여줄 수 있다.
* 면접 질문을 유도하기 좋다.

Trade-off:

* 문서 작성 시간이 필요하다.
* GIF 품질 관리가 필요하다.

---

# Future Decisions

추후 검토할 결정:

* Phase 2에서 HealthKit을 추가할지
* Swift Charts를 검사 탭에 도입할지
* Cloud sync를 지원할지
* UI Test 범위를 확대할지
* 다크모드를 완전 대응할지
* 생리 주기 / 배란일 계산을 추가할지

---

# Portfolio Principles

이 문서는 기술 선택의 이유를 설명하기 위한 문서다.

면접에서 강조할 포인트:

* 기술을 “썼다”보다 “왜 썼는가”
* 기능을 “뺐다”보다 “왜 MVP에서 제외했는가”
* 구조를 “나눴다”보다 “왜 나눴는가”
* 테스트를 “작성했다”보다 “왜 테스트 가능해졌는가”

우선순위:

1. 설명 가능한 선택
2. 현실적인 MVP 범위
3. 유지보수 가능한 구조
4. 포트폴리오 어필 포인트
5. 과하지 않은 설계
