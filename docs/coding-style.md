# Coding Style

## Goal

Aran은 포트폴리오 목적의 iOS 프로젝트다.

코드 스타일 목표:

* 명확한 책임 분리
* 예측 가능한 코드 흐름
* 읽기 쉬운 구조
* 테스트 가능한 구현
* 과도한 추상화 방지

이 프로젝트는 “짧은 코드”보다 “설명 가능한 코드”를 우선한다.

---

# General Principles

우선순위:

1. readability
2. explicit naming
3. predictable flow
4. testability
5. maintainability

지양:

* 과도한 Generic
* 사용 사례가 1개뿐인 추상화
* 불필요한 Protocol
* 불필요한 extension 분리
* 한 파일에 여러 책임 혼합

---

# Naming

## Type Naming

| Type                      | Suffix               |
| ------------------------- | -------------------- |
| SwiftUI View              | `View`               |
| UIKit Screen              | `ViewController`     |
| ViewModel                 | `ViewModel`          |
| UseCase                   | `UseCase`            |
| Repository Protocol       | `RepositoryProtocol` |
| Repository Implementation | `Repository`         |
| DTO                       | `DTO`                |
| SwiftData Model           | `Model`              |
| Mapper                    | `Mapper`             |

예시:

```swift id="j1yq6v"
CalendarView
MedicationViewController
DrugSearchViewModel
SearchDrugUseCase
DrugRepositoryProtocol
DrugRepository
DrugItemDTO
MedicationModel
DrugMapper
```

---

# Variable Naming

## Explicit Naming

좋은 예시:

```swift id="5g6wwy"
selectedDate
medicationSchedules
notificationIdentifier
searchKeyword
latestHealthRecord
```

지양:

```swift id="i2n6n7"
data
item
temp
list
value
obj
```

규칙:

* 의미 없는 축약어 금지
* bool은 상태가 드러나게 작성
* collection은 복수형 사용

좋은 예시:

```swift id="xajx2r"
isNotificationEnabled
hasTransferRecord
medications
healthRecords
```

---

# File Structure

## One Primary Responsibility

하나의 파일은 하나의 주요 책임만 가진다.

좋은 예시:

```text id="7kt8gr"
DrugSearchView
→ 검색 UI만 담당
```

지양:

```text id="eh9bgv"
DrugSearchView
→ API 호출
→ persistence 저장
→ notification 처리
→ analytics 처리
```

---

# File Size

권장 기준:

| Type           | Recommended  |
| -------------- | ------------ |
| ViewModel      | 200 lines 이하 |
| ViewController | 300 lines 이하 |
| View           | 150 lines 이하 |
| UseCase        | 가능한 단순 유지    |

강제 규칙은 아니지만 지나치게 커질 경우 책임 분리를 검토한다.

---

# MARK Style

구조를 명확히 구분한다.

예시:

```swift id="3ut5a3"
final class MedicationViewController: UIViewController {

    // MARK: - UI

    // MARK: - Properties

    // MARK: - Lifecycle

    // MARK: - Bind

    // MARK: - Actions

}
```

---

# Access Control

기본 원칙:

* 가능한 좁은 범위 사용
* 불필요한 public 금지

우선 사용:

```swift id="9ck12t"
private
private(set)
fileprivate 필요한 경우만
```

지양:

```swift id="v0j3gg"
public 남용
open 남용
```

---

# Dependency Injection

## Initializer Injection 우선

좋은 예시:

```swift id="iq6x1s"
final class SearchDrugUseCase {

    private let repository: DrugRepositoryProtocol

    init(repository: DrugRepositoryProtocol) {
        self.repository = repository
    }
}
```

지양:

```swift id="s0s2mj"
let repository = DrugRepository()
```

규칙:

* ViewModel 내부 객체 생성 금지
* Singleton 남용 금지
* 테스트 가능 구조 유지

---

# SwiftUI Style

## View Responsibility

View는 상태 표현 중심으로 유지한다.

허용:

* layout
* styling
* binding
* event 전달

금지:

* API 호출
* business logic
* persistence 처리
* 복잡한 계산

---

## ViewModel Responsibility

ViewModel은 상태 관리와 UseCase 실행 담당.

예시:

```swift id="s1m26s"
@Published var searchText = ""
@Published var drugs: [Drug] = []
```

규칙:

* API 호출은 ViewModel에서 수행
* Combine pipeline은 ViewModel에서 관리
* View 내부 async task 남용 금지

---

## Body Rule

body 내부 비즈니스 로직 금지.

좋은 예시:

```swift id="r5od3v"
var body: some View {
    contentView
}
```

지양:

```swift id="it0q2n"
var body: some View {
    if complexCalculation() {
        ...
    }
}
```

---

# UIKit Style

## ViewController Responsibility

ViewController는 bind 중심으로 작성한다.

허용:

* UI binding
* navigation
* user interaction
* layout

금지:

* business logic
* API call
* persistence access

---

## UITableView / UICollectionView

규칙:

* Cell 내부 비즈니스 로직 금지
* Cell은 display 전용
* Cell configure 메서드 단순 유지

예시:

```swift id="8y9xnl"
func configure(with medication: Medication)
```

---

# RxSwift Style

## Allowed

사용 권장:

* PublishRelay
* BehaviorRelay
* Driver
* DisposeBag

---

## Driver Rule

UI 출력은 가능하면 Driver 사용.

예시:

```swift id="gmcn64"
viewModel.medications
    .asDriver()
```

이유:

* main thread 보장
* error 방지
* sharing 보장

---

## Relay Rule

### PublishRelay

사용자 이벤트 전달.

예시:

```swift id="i9wxf6"
addButtonTapped
searchTextChanged
```

---

### BehaviorRelay

현재 상태 유지.

예시:

```swift id="xwzzyx"
medications
selectedDate
```

---

## Forbidden

금지:

* Raw Observable 직접 UI 바인딩
* nested subscribe
* ViewController 내부 비즈니스 로직

지양:

```swift id="ifjcl6"
observable.subscribe {
    observable2.subscribe {
    }
}
```

---

# Combine Style

## Allowed

사용 권장:

* @Published
* ObservableObject
* debounce
* replaceError
* removeDuplicates

---

## Search Debounce

기본 debounce:

```swift id="jjlwm5"
0.3 seconds
```

예시:

```swift id="0ns89y"
.debounce(
    for: .milliseconds(300),
    scheduler: RunLoop.main
)
```

---

## Forbidden

금지:

* View 내부 API 호출
* body 내부 비즈니스 로직
* 과도한 AnyPublisher 노출

---

# Async/Await Style

## Preferred

신규 비동기 코드는 async/await 사용.

예시:

```swift id="2m5x5y"
func fetchDrugs() async throws
```

---

## Forbidden

지양:

* callback hell
* completion nesting
* DispatchQueue 남용

---

# Error Handling

## Error Policy

규칙:

* Empty Result는 정상 UX Case
* fatalError 남용 금지
* force unwrap 금지
* 사용자 입력 오류를 crash로 처리 금지

---

## User Facing Error

좋은 예시:

```text id="q5s0mf"
검색 결과가 없어요
```

```text id="4i0ftm"
네트워크 오류가 발생했어요
```

지양:

```text id="2bjlwm"
unexpected failure
```

---

# Force Unwrap

금지:

```swift id="wst8vl"
value!
```

허용:

* 테스트 코드
* 명백한 invariant 보장 상황

우선 사용:

```swift id="73rbxa"
guard let
if let
```

---

# Extension Rule

extension은 역할별로 분리한다.

좋은 예시:

```swift id="s3eh9m"
extension MedicationViewController: UITableViewDelegate
```

```swift id="cbx2yj"
extension DrugSearchViewModel {
    func bindSearch()
}
```

---

# Comment Policy

코드는 가능한 self-documenting하게 작성한다.

주석 사용 기준:

허용:

* 의도 설명
* workaround 설명
* 기술 선택 이유

지양:

```swift id="4vr78e"
// increment count
count += 1
```

---

# Magic Number

하드코딩 숫자 최소화.

좋은 예시:

```swift id="wt6kr9"
private enum Layout {
    static let cornerRadius: CGFloat = 12
}
```

지양:

```swift id="9a5x5m"
view.layer.cornerRadius = 12
```

---

# DTO / Entity Separation

절대 혼합 금지.

금지:

```swift id="h2m4bw"
DrugItemDTO
→ View 직접 전달
```

반드시:

```text id="jqx6fw"
DTO
→ Mapper
→ Entity
→ ViewModel
```

---

# SwiftData Style

## Persistence Model Rule

SwiftData Model은 persistence 전용이다.

금지:

* View 직접 전달
* UI formatting 포함
* business logic 포함

---

## Entity Conversion

반드시 Mapper를 통해 변환한다.

예시:

```text id="g0a1yv"
MedicationModel
→ MedicationMapper
→ Medication Entity
```

---

# Notification Style

알림은 schedule 단위로 관리한다.

예시:

```swift id="j4d9ah"
notificationId
isNotificationEnabled
```

규칙:

* 수정 시 기존 알림 취소 후 재등록
* identifier는 명확한 naming 사용

---

# Testing Style

## Test Naming

패턴:

```text id="3xpv92"
test_기능_상황_결과
```

예시:

```swift id="ffm0vl"
test_searchDrug_whenKeywordIsEmpty_thenThrowsError()
```

---

## Test Structure

패턴:

```text id="l98go0"
given
when
then
```

---

## Mock Rule

Mock은 테스트 타겟 내부에 둔다.

예시:

```text id="1q3n55"
AranTests/Mocks
```

---

# Git Style

## Commit Principle

한 커밋은 하나의 목적만 가진다.

좋은 예시:

```text id="suk5rc"
feat: add medication notification scheduling
```

지양:

```text id="p03xkp"
fix everything
```

---

# Portfolio Principles

이 프로젝트는 포트폴리오 목적의 앱이다.

우선순위:

1. 설명 가능한 코드
2. 테스트 가능한 구조
3. 명확한 책임 분리
4. 읽기 쉬운 흐름
5. 유지보수성

지양:

* clever code
* over engineering
* unnecessary abstraction
* generic abuse
* reactive 혼합 난립

명확성과 일관성을 우선한다.
