# Architecture

## Goal

Aran은 Clean Architecture + MVVM 기반의 iOS 포트폴리오 앱이다.

목표:

* 비즈니스 로직을 UI, DB, 네트워크, 알림 프레임워크로부터 분리한다.
* UIKit/RxSwift와 SwiftUI/Combine을 feature 단위로 명확히 구분한다.
* UseCase와 ViewModel을 테스트 가능한 구조로 유지한다.
* 외부 기술 의존성을 Infrastructure 계층에 캡슐화한다.
* 면접에서 설명 가능한 명확한 구조를 유지한다.

이 프로젝트는 복잡한 구조보다 명확한 책임 분리를 우선한다.

---

# Target Structure

앱 소스와 테스트 코드는 Xcode Target 기준으로 분리한다.

```text
Aran
├── Application
├── Common
├── Presentation
├── Domain
├── Data
├── Infrastructure
└── Resources

AranTests
├── Domain
├── Presentation
├── Data
└── Mocks

AranUITests
└── Flows
```

## Target Rules

* `Aran`은 실제 앱 소스 코드 타겟이다.
* `AranTests`는 Unit Test 타겟이다.
* `AranUITests`는 UI Test 타겟이다.
* 테스트 코드는 앱 소스 폴더 내부에 두지 않고 별도 테스트 타겟에서 관리한다.
* 테스트 타겟은 앱 모듈을 import하여 검증한다.
* Mock 객체는 테스트 타겟 내부에 둔다.

---

# App Source Structure

```text
Aran
├── Application
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── AppCoordinator.swift
│   └── DIContainer.swift
│
├── Common
│   ├── Extensions
│   ├── DesignSystem
│   ├── Constants
│   ├── Errors
│   └── Utilities
│
├── Presentation
│   ├── Calendar
│   ├── Medication
│   ├── HealthRecord
│   ├── DrugInfo
│   └── Common
│
├── Domain
│   ├── Entities
│   ├── UseCases
│   ├── Repositories
│   └── Errors
│
├── Data
│   ├── Repositories
│   ├── DTOs
│   ├── Mappers
│   ├── Local
│   └── Remote
│
├── Infrastructure
│   ├── Network
│   ├── Persistence
│   ├── Notifications
│   └── Configuration
│
└── Resources
    ├── Assets.xcassets
    ├── Info.plist
    └── Localizable.strings
```

---

# Layer Responsibilities

## Application

앱 진입점과 전체 흐름을 조립하는 계층이다.

포함:

* AppDelegate
* SceneDelegate
* AppCoordinator
* DIContainer
* RootViewController 구성
* App Lifecycle 처리

역할:

* 앱 시작 흐름 구성
* Feature 진입점 연결
* UseCase / Repository / Infrastructure 객체 조립
* Root Navigation 관리

규칙:

* 비즈니스 로직을 직접 가지지 않는다.
* 외부 API 호출을 직접 수행하지 않는다.
* 화면 내부 상태를 관리하지 않는다.
* 객체 생성과 흐름 연결에 집중한다.

---

## Presentation

UI와 사용자 이벤트를 처리하는 계층이다.

포함:

* SwiftUI View
* UIKit ViewController
* ViewModel
* Custom Cell
* View Component
* Presentation 전용 State

Feature Stack:

| Feature                | Stack             |
| ---------------------- | ----------------- |
| Calendar               | SwiftUI + Combine |
| DrugInfo               | SwiftUI + Combine |
| Medication / Injection | UIKit + RxSwift   |
| HealthRecord           | UIKit + RxSwift   |

허용 의존성:

* Domain
* UIKit
* SwiftUI
* Combine
* RxSwift / RxCocoa

금지:

* SwiftData 직접 접근
* Alamofire 직접 호출
* UserNotifications 직접 호출
* DTO 직접 사용
* Repository 구현체 직접 참조
* View/ViewController 내부 비즈니스 로직

규칙:

* ViewModel은 UseCase를 통해서만 비즈니스 로직을 실행한다.
* View는 상태를 표현하고 사용자 이벤트를 전달한다.
* ViewController는 UI 바인딩과 화면 전환에 집중한다.
* 입력 검증은 ViewModel에서 수행한다.
* Presentation은 Domain Entity를 화면 표시용 State로 변환할 수 있다.

---

## Domain

앱의 핵심 비즈니스 규칙을 담는 계층이다.

포함:

* Entity
* UseCase
* Repository Protocol
* Domain Error
* Value Object

예시:

```text
Domain
├── Entities
│   ├── CycleRecord.swift
│   ├── TransferRecord.swift
│   ├── Medication.swift
│   ├── MedicationSchedule.swift
│   ├── HealthRecord.swift
│   └── Drug.swift
│
├── UseCases
│   ├── CycleRecordUseCase.swift
│   ├── MedicationUseCase.swift
│   ├── MedicationNotificationUseCase.swift
│   ├── HealthRecordUseCase.swift
│   └── SearchDrugUseCase.swift
│
├── Repositories
│   ├── CycleRecordRepositoryProtocol.swift
│   ├── MedicationRepositoryProtocol.swift
│   ├── NotificationRepositoryProtocol.swift
│   ├── HealthRecordRepositoryProtocol.swift
│   └── DrugRepositoryProtocol.swift
│
└── Errors
    └── DomainError.swift
```

금지 의존성:

* UIKit
* SwiftUI
* RxSwift
* Combine
* SwiftData
* Alamofire
* UserNotifications

규칙:

* 순수 Swift 타입으로 유지한다.
* 외부 프레임워크 타입을 노출하지 않는다.
* Repository는 Protocol만 정의한다.
* UseCase는 Repository Protocol에 의존한다.
* 테스트 가능한 비즈니스 로직을 이 계층에 둔다.

---

## Data

Domain Repository Protocol을 구현하는 계층이다.

포함:

* Repository 구현체
* DTO
* Mapper
* Local DataSource
* Remote DataSource

예시:

```text
Data
├── Repositories
│   ├── DrugRepository.swift
│   ├── MedicationRepository.swift
│   ├── HealthRecordRepository.swift
│   └── CycleRecordRepository.swift
│
├── DTOs
│   └── Drug
│       ├── DrugSearchResponseDTO.swift
│       ├── DrugItemDTO.swift
│       └── DrugDetailResponseDTO.swift
│
├── Mappers
│   ├── DrugMapper.swift
│   ├── MedicationMapper.swift
│   ├── HealthRecordMapper.swift
│   └── CycleRecordMapper.swift
│
├── Local
│   ├── Models
│   └── DataSources
│
└── Remote
    ├── API
    └── DataSources
```

역할:

* Infrastructure를 사용해 실제 데이터 입출력을 수행한다.
* DTO / SwiftData Model을 Domain Entity로 변환한다.
* Domain Repository Protocol을 구현한다.

규칙:

* DTO를 Domain 또는 Presentation으로 노출하지 않는다.
* SwiftData Model을 Domain 또는 Presentation으로 노출하지 않는다.
* API 응답은 DTO로 decode한 뒤 Entity로 변환한다.
* Persistence Model은 Entity로 변환한 뒤 반환한다.
* Infrastructure error를 앱에서 처리 가능한 error로 변환한다.

데이터 흐름:

```text
Remote API
→ DTO
→ Mapper
→ Domain Entity
→ UseCase
→ ViewModel
→ View
```

```text
SwiftData Model
→ Mapper
→ Domain Entity
→ UseCase
→ ViewModel
→ View
```

---

## Infrastructure

외부 기술 세부사항을 캡슐화하는 계층이다.

포함:

* Alamofire API Client
* API Router
* SwiftData Stack
* UserNotifications Manager
* App Configuration
* Secure Configuration Loader

예시:

```text
Infrastructure
├── Network
│   ├── APIClient.swift
│   ├── DrugRouter.swift
│   └── NetworkError.swift
│
├── Persistence
│   ├── SwiftDataStack.swift
│   └── ModelContainerProvider.swift
│
├── Notifications
│   ├── NotificationManager.swift
│   └── NotificationError.swift
│
└── Configuration
    ├── AppConfiguration.swift
    └── APIKeyProvider.swift
```

규칙:

* 외부 라이브러리와 플랫폼 API 세부사항을 캡슐화한다.
* API Key, Secret, 개인정보를 하드코딩하지 않는다.
* Domain에 의존하지 않는다.
* 비즈니스 판단을 포함하지 않는다.
* 외부 기술 변경 시 Data/Application에 미치는 영향을 최소화한다.

---

## Common

프로젝트 전역에서 사용할 수 있는 공통 코드 계층이다.

포함:

* Extensions
* DesignSystem
* Constants
* Common Error
* Formatter
* Shared UI Component
* Utility

규칙:

* Feature 비즈니스 로직을 포함하지 않는다.
* 특정 화면에 종속된 코드는 넣지 않는다.
* Domain 규칙을 Common으로 이동하지 않는다.
* 여러 계층에서 재사용 가능한 코드만 둔다.

---

# Dependency Direction

허용 방향:

```text
Presentation -> Domain
Data -> Domain
Data -> Infrastructure
Application -> Presentation
Application -> Domain
Application -> Data
Application -> Infrastructure
```

요약:

```text
Presentation -> Domain <- Data
Application -> Presentation / Domain / Data / Infrastructure
Data -> Infrastructure
```

금지 방향:

```text
Domain -> Presentation
Domain -> Data
Domain -> Infrastructure
Presentation -> Data
Presentation -> Infrastructure
Infrastructure -> Domain
Infrastructure -> Presentation
```

핵심 규칙:

* Domain은 가장 안쪽 계층이며 어떤 외부 계층도 알지 못한다.
* Presentation은 Data 구현체를 직접 알지 못한다.
* Data는 Domain Protocol을 구현한다.
* Infrastructure는 기술 세부사항만 담당한다.
* Application이 객체 조립과 연결을 담당한다.

---

# Dependency Injection

DI는 Initializer Injection을 기본으로 한다.

예시:

```swift
final class SearchDrugUseCase {
    private let repository: DrugRepositoryProtocol

    init(repository: DrugRepositoryProtocol) {
        self.repository = repository
    }

    func execute(keyword: String) async throws -> [Drug] {
        try await repository.search(keyword: keyword)
    }
}
```

ViewModel 예시:

```swift
@MainActor
final class DrugSearchViewModel: ObservableObject {
    private let searchDrugUseCase: SearchDrugUseCase

    init(searchDrugUseCase: SearchDrugUseCase) {
        self.searchDrugUseCase = searchDrugUseCase
    }
}
```

규칙:

* Singleton 남용 금지
* Repository 구현체 직접 생성 금지
* ViewModel 내부에서 Repository 직접 생성 금지
* 테스트에서 Mock Repository 교체 가능해야 함
* DIContainer는 Application 계층에서 관리

---

# Feature Stack Policy

## SwiftUI + Combine Features

대상:

* Calendar
* DrugInfo

사용:

* `@StateObject`
* `@Published`
* `ObservableObject`
* `PassthroughSubject`
* `.debounce()`
* `.catch()`
* `.replaceError()`

규칙:

* API 호출은 ViewModel에서 수행한다.
* View는 상태 표현과 이벤트 전달만 담당한다.
* 복잡한 날짜 계산은 UseCase에서 수행한다.
* Combine pipeline은 ViewModel 내부에 둔다.

---

## UIKit + RxSwift Features

대상:

* Medication / Injection
* HealthRecord

사용:

* `PublishRelay`
* `BehaviorRelay`
* `Driver`
* `DisposeBag`
* `UITableView`
* `UICollectionView` 필요한 경우

규칙:

* ViewController는 bind 중심으로 작성한다.
* UI 출력은 가능하면 `Driver`로 변환한다.
* 사용자 입력 이벤트는 `PublishRelay`로 전달한다.
* 현재 상태가 필요한 값은 `BehaviorRelay`를 사용한다.
* Cell 재사용 시 DisposeBag lifecycle을 명확히 관리한다.

---

# Bridging Policy

SwiftUI와 UIKit 브리징은 명확한 이유가 있을 때만 사용한다.

허용 예시:

```text
Medication Flow
→ UIHostingController
→ DrugSearchView(register mode)
→ selected drug
→ MedicationFormViewController
```

허용 기술:

* UIHostingController
* UIViewRepresentable

규칙:

* 단순 UI 구현을 위해 브리징을 남용하지 않는다.
* Feature 내부 reactive stack을 섞기 위한 목적으로 브리징하지 않는다.
* 브리징 지점은 Presentation 계층에 둔다.
* 브리징 이유가 코드상 명확해야 한다.

---

# DrugSearch Reuse Flow

DrugSearch는 두 가지 mode를 가진 공통 검색 컴포넌트다.

```swift
enum DrugSearchMode {
    case browse
    case register
}
```

## browse mode

사용 위치:

* Drug Information Tab

흐름:

```text
DrugInfo Tab
→ DrugSearchView(mode: .browse)
→ Search Result
→ Drug Detail
```

## register mode

사용 위치:

* Medication / Injection Tab

흐름:

```text
Medication Tab
→ Add Medication
→ UIHostingController
→ DrugSearchView(mode: .register)
→ Select Drug
→ MedicationFormViewController
```

규칙:

* 검색 로직은 SearchDrugUseCase를 공유한다.
* mode에 따라 선택 후 동작만 달라진다.
* API 결과가 없으면 직접 입력 fallback을 제공한다.

---

# Error Handling Policy

## Empty Result

검색 결과 없음은 정상 UX Case다.

예:

```text
Drug Search Empty Result
→ 직접 입력하기 표시
```

## Network Error

네트워크 오류는 재시도와 fallback을 제공한다.

예:

```text
Network Error
→ Retry
→ 실패 시 직접 입력 안내
```

## Validation Error

입력 오류는 throw보다 UI 상태로 처리한다.

예:

```text
Invalid dosage input
→ Save button disabled
→ Validation message
```

규칙:

* 사용자 입력 오류를 crash로 처리하지 않는다.
* API empty result를 fatal error로 처리하지 않는다.
* Repository는 Infrastructure error를 앱에서 이해 가능한 error로 변환한다.

---

# Testing Architecture

테스트 코드는 앱 소스와 분리된 테스트 타겟에 둔다.

```text
AranTests
├── Domain
│   └── UseCases
├── Presentation
│   └── ViewModels
├── Data
│   └── Repositories
└── Mocks
```

우선 테스트 대상:

* UseCase
* ViewModel
* Repository

Mock 위치:

```text
AranTests/Mocks
```

Mock 예시:

* MockDrugRepository
* MockMedicationRepository
* MockHealthRecordRepository
* MockCycleRecordRepository
* MockNotificationRepository

규칙:

* Domain UseCase는 UI, DB, Network 없이 테스트 가능해야 한다.
* ViewModel은 Mock UseCase 또는 Mock Repository 기반으로 테스트한다.
* UI Test는 핵심 플로우만 별도 `AranUITests`에서 작성한다.

---

# Portfolio Principles

이 프로젝트는 포트폴리오 목적의 앱이다.

우선순위:

1. 명확한 책임 분리
2. 설명 가능한 기술 선택
3. 테스트 가능한 UseCase 구조
4. Feature별 일관된 reactive stack
5. 유지보수 가능한 파일 구조
6. 과하지 않은 추상화

지양:

* 사용 사례가 1개뿐인 불필요한 Protocol
* 과도한 Generic 기반 추상화
* Feature 내부 RxSwift / Combine 혼합
* ViewModel에 모든 로직 집중
* Data/Domain/Persistence 모델 혼합
* UI에서 직접 API 호출
