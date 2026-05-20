# Concurrency

## Goal

Aran은 Swift 6 기준의 concurrency 환경을 고려하여 작성한다.

목표:

* UI thread 안정성 유지
* async/await 기반 비동기 흐름 유지
* RxSwift와 Swift Concurrency 충돌 최소화
* SwiftUI/Combine과 UIKit/RxSwift 혼합 환경 안정화
* 점진적 Swift 6 대응 전략 유지

이 프로젝트는 “완전한 strict concurrency 대응”보다 “안정적이고 설명 가능한 구조”를 우선한다.

---

# Core Principles

우선순위:

1. UI 안정성
2. Main Thread 보장
3. 명확한 async 흐름
4. 테스트 가능성
5. 최소한의 warning suppression

지양:

* 무분별한 `@unchecked Sendable`
* 불필요한 actor hopping
* legacy callback 혼합
* concurrency warning 전체 무시

---

# Swift Version Policy

기준:

```text
Swift 6
iOS 17+
```

규칙:

* 신규 비동기 코드는 async/await 사용
* Swift Concurrency 중심 유지
* 필요한 경우에만 RxSwift bridge 허용
* strict concurrency warning은 점진적으로 대응

---

# MainActor Policy

## UI Layer

UI 관련 객체는 `@MainActor` 우선 적용한다.

대상:

* SwiftUI ViewModel
* UIKit ViewModel
* UI State Object

예시:

```swift
@MainActor
final class DrugSearchViewModel: ObservableObject {

}
```

---

## Why

이유:

* UI state thread safety 보장
* Combine state update 안정화
* Rx UI binding 안정화
* main thread dispatch 최소화

---

## Forbidden

지양:

```swift
DispatchQueue.main.async {
}
```

필요 이상으로 main queue hopping하지 않는다.

---

# Async/Await Policy

## Preferred Style

신규 비동기 코드는 async/await 사용.

좋은 예시:

```swift
func search(keyword: String) async throws -> [Drug]
```

지양:

```swift
func search(
    keyword: String,
    completion: @escaping ([Drug]) -> Void
)
```

---

# Layer Usage

## Infrastructure

네트워크 및 persistence layer는 async/await 중심으로 구현한다.

예시:

```swift
let dto: DrugResponseDTO = try await apiClient.request(router)
```

---

## Repository

Repository는 async API를 Domain에 제공한다.

예시:

```swift
protocol DrugRepositoryProtocol {
    func search(keyword: String) async throws -> [Drug]
}
```

---

## UseCase

UseCase는 async 비즈니스 흐름 처리 가능.

예시:

```swift
func execute(keyword: String) async throws -> [Drug]
```

---

# RxSwift Concurrency Policy

## @preconcurrency

RxSwift import에는 필요한 범위에서만 `@preconcurrency` 허용.

예시:

```swift
@preconcurrency import RxSwift
@preconcurrency import RxCocoa
```

목적:

* Swift 6 Sendable warning 완화
* legacy reactive library 호환 유지

---

## Rules

규칙:

* 프로젝트 전체 blanket suppression 금지
* 필요한 파일에만 제한적으로 적용
* warning suppression 이유를 설명 가능해야 한다

---

# Sendable Policy

## 기본 원칙

무분별한 `Sendable` 채택 금지.

우선:

* value type 유지
* immutable state 유지
* MainActor isolation 유지

---

## Forbidden

금지:

```swift
@unchecked Sendable
```

허용 조건:

* 외부 라이브러리 호환 문제
* thread safety 명확히 보장되는 경우
* workaround 이유가 코드상 설명 가능한 경우

---

# Actor Policy

## Current Strategy

MVP 기준:

* MainActor 중심
* custom actor 최소화

이유:

* 앱 규모 대비 complexity 증가 방지
* RxSwift/Combine 혼합 환경 단순화
* 설명 가능한 구조 유지

---

## Future Expansion

Phase 2 이상에서 필요 시 검토:

* persistence actor
* background sync actor
* analytics actor

MVP에서는 도입하지 않는다.

---

# Thread Safety Policy

## UI State

UI 상태는 MainActor에서만 수정한다.

예시:

```swift
@Published var medications: [Medication] = []
```

규칙:

* background thread에서 UI state 수정 금지
* ViewModel이 UI state mutation 담당

---

## Shared Mutable State

공유 mutable state 최소화.

지양:

```swift
static var sharedState
```

권장:

* dependency injection
* immutable data flow
* MainActor isolation

---

# Combine Concurrency Policy

## Scheduler

UI 업데이트는 main thread 보장.

예시:

```swift
.receive(on: RunLoop.main)
```

---

## Debounce

검색 debounce는 main scheduler 기준 사용.

예시:

```swift
.debounce(
    for: .milliseconds(300),
    scheduler: RunLoop.main
)
```

---

## State Update

`@Published` state는 MainActor 내부에서 업데이트한다.

좋은 예시:

```swift
@MainActor
func fetch() async {
    drugs = result
}
```

---

# RxSwift Concurrency Policy

## Driver Usage

UI 바인딩은 Driver 우선.

이유:

* main thread 보장
* error propagation 방지
* shared side effect 안정화

예시:

```swift
viewModel.medications
    .asDriver()
```

---

## Background Work

무거운 작업은 background scheduler 사용 가능.

예시:

```swift
.subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
```

단:

* UI update는 main thread 복귀 필수

---

# Notification Concurrency Policy

UserNotifications 작업은 async 흐름 기준 관리.

예시:

```swift
try await notificationRepository.schedule(
    medication: medication
)
```

규칙:

* schedule update 시 race condition 방지
* 수정 시 기존 알림 먼저 제거
* notificationId consistency 유지

---

# SwiftData Concurrency Policy

## MVP Strategy

MVP에서는 복잡한 multi-context 구조 사용하지 않는다.

기본 전략:

* MainActor 중심
* 단순 persistence flow 유지

이유:

* SwiftData complexity 최소화
* 포트폴리오 목적 구조 단순화

---

## Rules

규칙:

* ViewContext 남용 금지
* persistence 직접 접근 금지
* Repository를 통해 접근

---

# Cancellation Policy

## Search Cancellation

검색 중 새로운 검색어 입력 시 이전 요청 취소 가능해야 한다.

예시 흐름:

```text
Search "프"
→ Request A

Search "프로"
→ Cancel A
→ Request B
```

---

## Task Management

ViewModel 내부 Task lifecycle 명확히 관리.

지양:

```swift
Task {
}
```

무분별한 fire-and-forget 사용 금지.

---

# Memory Safety Policy

## Retain Cycle

비동기 closure에서 retain cycle 방지.

예시:

```swift
[weak self]
```

단:

* 무조건 weak self 남용하지 않는다
* lifecycle이 명확한 경우 강한 참조 허용 가능

---

# Error Propagation Policy

비동기 에러는 명확하게 전달한다.

예시:

```swift
throws
Result
Published Error State
```

금지:

```swift
catch {
}
```

silent failure 금지.

---

# Logging Policy

Debug logging 최소화.

금지:

```swift
print()
```

권장:

```swift
Logger
```

또는 debug build 한정 logging.

---

# Migration Strategy

## Current Strategy

현재 전략:

```text
Swift Concurrency
+
RxSwift coexistence
```

목표:

* UIKit Feature는 RxSwift 유지
* SwiftUI Feature는 Combine 유지
* async/await 중심 비동기 흐름 유지

---

## Non-goal

MVP에서 하지 않는 것:

* RxSwift 제거
* 전체 Combine 통합
* full actor architecture
* complete Sendable compliance

---

# Testing Concurrency

테스트 시 검증 대상:

* async UseCase
* cancellation flow
* state update
* error propagation
* debounce behavior

예시:

```swift
func test_search_whenCancelled_thenDoesNotUpdateState()
```

---

# Portfolio Principles

이 프로젝트에서 concurrency 전략은 “최신 기술 적용”보다 “현실적인 혼합 환경 대응”에 목적이 있다.

설명 가능한 포인트:

* 왜 async/await를 선택했는가
* 왜 RxSwift를 유지했는가
* 왜 MainActor 중심 구조를 택했는가
* 왜 full actor model을 도입하지 않았는가
* 왜 @preconcurrency를 제한적으로 사용했는가

우선순위:

1. UI 안정성
2. 설명 가능한 구조
3. 점진적 Swift 6 대응
4. 테스트 가능성
5. 유지보수성
