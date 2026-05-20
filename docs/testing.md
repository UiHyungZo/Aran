# Testing

## Goal

Aran의 테스트 전략은 Clean Architecture를 선택한 이유를 증명하는 것이다.

목표:

* 핵심 비즈니스 로직을 UI 없이 검증한다.
* 네트워크, DB, 알림 의존성 없이 UseCase를 테스트한다.
* ViewModel의 상태 변화와 입력 검증을 테스트한다.
* Repository 구현의 Mapping / Error Handling을 검증한다.
* 포트폴리오에서 “테스트 가능한 구조”를 설명할 수 있게 한다.

---

# Test Targets

테스트 코드는 앱 소스 타겟과 분리된 Xcode 테스트 타겟에 둔다.

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

규칙:

* Unit Test는 `AranTests`에 작성한다.
* UI Test는 `AranUITests`에 작성한다.
* Mock 객체는 앱 소스가 아니라 테스트 타겟 내부에 둔다.
* 테스트 타겟은 앱 모듈을 import하여 검증한다.

---

# Test Priority

우선순위:

1. UseCase Unit Test
2. ViewModel Unit Test
3. Repository / Mapper Test
4. Core UI Flow Test

MVP에서는 UseCase 테스트를 가장 우선한다.

---

# Unit Test Scope

## Primary Targets

필수 테스트 대상:

* CycleRecordUseCase
* MedicationNotificationUseCase
* SearchDrugUseCase
* HealthRecordUseCase

권장 테스트 대상:

* DrugSearchViewModel
* MedicationViewModel
* HealthRecordViewModel
* DrugRepository
* Mapper

---

# UseCase Test Targets

| UseCase                       | Required Coverage                        |
| ----------------------------- | ---------------------------------------- |
| CycleRecordUseCase            | 채취 저장, 차수별 조회, 이식 결과 업데이트                |
| MedicationNotificationUseCase | 알림 등록, 수정 시 기존 알림 취소 후 재등록, 비활성화 시 알림 삭제 |
| SearchDrugUseCase             | 정상 검색, 빈 검색어, 네트워크 실패 전파                 |
| HealthRecordUseCase           | 수치 저장, 항목별 조회, 날짜순 정렬                    |

---

# Test Style

모든 테스트는 가능하면 given / when / then 구조를 따른다.

```swift
func test_searchDrug_whenKeywordIsEmpty_thenThrowsError() async {
    // given

    // when

    // then
}
```

규칙:

* 테스트 이름은 상황과 기대 결과를 드러낸다.
* 하나의 테스트는 하나의 동작만 검증한다.
* 테스트 내부에서 실제 네트워크를 호출하지 않는다.
* 테스트 내부에서 실제 알림을 등록하지 않는다.
* 테스트 내부에서 실제 DB에 의존하지 않는다.

---

# Test Naming

권장 패턴:

```text
test_기능_when상황_then결과
```

예시:

```swift
test_searchDrug_whenKeywordIsEmpty_thenThrowsValidationError()
test_saveHealthRecord_whenValueIsValid_thenStoresRecord()
test_scheduleMedication_whenNotificationEnabled_thenRegistersNotification()
test_updateMedicationSchedule_whenTimeChanged_thenCancelsOldNotification()
```

---

# Mock Strategy

Mock Repository는 테스트 타겟 내부에 둔다.

```text
AranTests
└── Mocks
    ├── MockDrugRepository.swift
    ├── MockMedicationRepository.swift
    ├── MockHealthRecordRepository.swift
    ├── MockCycleRecordRepository.swift
    └── MockNotificationRepository.swift
```

Mock은 다음 기능을 지원한다.

* Stubbed success value
* Stubbed error
* Captured input
* Call count verification
* Invocation order 검증이 필요한 경우 최소한으로 지원

---

# Mock Example

```swift
final class MockDrugRepository: DrugRepositoryProtocol {

    var searchResult: Result<[Drug], Error> = .success([])
    private(set) var receivedKeyword: String?
    private(set) var searchCallCount = 0

    func search(keyword: String) async throws -> [Drug] {
        searchCallCount += 1
        receivedKeyword = keyword

        switch searchResult {
        case .success(let drugs):
            return drugs
        case .failure(let error):
            throw error
        }
    }
}
```

---

# UseCase Testing

## SearchDrugUseCase

검증 항목:

* 정상 검색 시 Drug 배열 반환
* 빈 검색어 입력 시 API 호출하지 않음
* 최소 글자 수 미달 시 validation error
* Repository error 전파
* 검색어 trim 처리

예시:

```swift
func test_searchDrug_whenKeywordIsEmpty_thenDoesNotCallRepository() async {
    // given
    let repository = MockDrugRepository()
    let useCase = SearchDrugUseCase(repository: repository)

    // when
    do {
        _ = try await useCase.execute(keyword: "")
        XCTFail("Expected error")
    } catch {
        // then
        XCTAssertEqual(repository.searchCallCount, 0)
    }
}
```

---

## MedicationNotificationUseCase

검증 항목:

* 복용 시간별 알림 등록
* 알림 수정 시 기존 알림 취소
* 알림 수정 시 새 알림 재등록
* 약 비활성화 시 관련 알림 취소
* notificationId 안정성 유지

---

## CycleRecordUseCase

검증 항목:

* 채취 기록 저장
* 차수별 기록 조회
* 이식 기록 추가
* 이식 결과 업데이트
* 날짜 기준 조회

---

## HealthRecordUseCase

검증 항목:

* 검사 수치 저장
* 항목별 최신값 조회
* 날짜순 정렬
* 이전 수치 대비 증감 계산
* 잘못된 수치 입력 처리

---

# ViewModel Testing

ViewModel 테스트는 상태 변화와 사용자 입력 이벤트를 검증한다.

## SwiftUI + Combine ViewModel

대상:

* CalendarViewModel
* DrugSearchViewModel

검증 항목:

* searchText 변경 시 debounce 이후 검색 실행
* loading 상태 변경
* empty state 변경
* error state 변경
* selectedDate 변경
* bottom sheet 표시 상태 변경

규칙:

* View를 띄우지 않고 ViewModel만 테스트한다.
* Combine scheduler 제어가 어려운 경우 debounce 로직은 최소 단위로 분리한다.

---

## UIKit + RxSwift ViewModel

대상:

* MedicationViewModel
* HealthRecordViewModel

검증 항목:

* 입력값 validation
* 저장 버튼 활성/비활성
* cell state 생성
* check toggle 상태 변경
* error state 생성

규칙:

* ViewController 없이 ViewModel만 테스트한다.
* Rx output은 테스트 가능한 형태로 구독한다.
* DisposeBag lifecycle을 명확히 처리한다.

---

# Repository Testing

Repository 테스트는 필요할 때만 작성한다.

대상:

* DrugRepository
* MedicationRepository
* HealthRecordRepository
* CycleRecordRepository

검증 항목:

* DTO → Entity mapping
* SwiftData Model → Entity mapping
* Infrastructure error → App error 변환
* Empty response 처리
* Decoding failure 처리

규칙:

* 실제 API 호출 테스트는 기본적으로 하지 않는다.
* APIClient를 Mock으로 교체한다.
* Local Repository는 in-memory container를 사용할 수 있다.

---

# Mapper Testing

Mapper는 별도 테스트할 수 있다.

검증 항목:

* DTO nil field 처리
* optional field 변환
* API 필드명과 Entity 필드 매핑
* SwiftData Model relationship 변환

예시:

```swift
func test_mapDrugDTO_whenOptionalFieldsAreNil_thenCreatesEntityWithNilValues() {
    // given

    // when

    // then
}
```

---

# UI Test Scope

UI Test는 핵심 플로우만 작성한다.

MVP 필수는 아니며, 시간이 부족할 경우 Phase 2로 이월 가능하다.

권장 시나리오:

1. 캘린더 날짜 탭 → 바텀시트 표시
2. 약 검색 → 약 등록 폼 이동
3. 약 복용 시간 저장 → 알림 설정 흐름
4. 검사 수치 입력 → 목록 반영
5. 약 검색 결과 → 상세 화면 이동

규칙:

* 모든 UI를 세세하게 테스트하지 않는다.
* 포트폴리오에서는 핵심 사용자 흐름만 검증한다.
* flaky test가 많아지면 범위를 줄인다.

---

# Coverage Target

권장 목표:

| Layer                     | Target      |
| ------------------------- | ----------- |
| Domain / UseCases         | 80%+        |
| Data / Repositories       | 60%+        |
| Presentation / ViewModels | 50%+        |
| UI Tests                  | 핵심 플로우 1~5개 |

Coverage 숫자보다 중요한 것은 핵심 비즈니스 로직이 독립적으로 테스트 가능한 구조인지다.

---

# TDD Policy

MVP에서는 UseCase 중심 TDD를 적용한다.

필수 TDD 대상:

* CycleRecordUseCase
* MedicationNotificationUseCase
* SearchDrugUseCase
* HealthRecordUseCase

흐름:

```text
Failing Test
→ Minimal Implementation
→ Refactor
```

규칙:

* 모든 화면을 TDD로 작성하려고 하지 않는다.
* 핵심 비즈니스 로직에 집중한다.
* UI는 일반 개발 후 필요한 부분만 테스트한다.

---

# Test Data Policy

테스트 데이터는 명확하게 작성한다.

좋은 예시:

```swift
let medication = Medication(
    id: UUID(),
    name: "프로게스테론",
    dosage: "200mg",
    isActive: true,
    schedules: []
)
```

지양:

```swift
let item = makeDummy()
```

단, 반복이 많아지면 Fixture를 사용할 수 있다.

---

# Fixture Policy

반복 테스트 데이터는 Fixture로 분리 가능하다.

```text
AranTests
└── Fixtures
    ├── DrugFixture.swift
    ├── MedicationFixture.swift
    └── HealthRecordFixture.swift
```

규칙:

* Fixture는 테스트 가독성을 해치지 않아야 한다.
* 너무 추상적인 fixture factory는 지양한다.

---

# Test Anti-patterns

금지 또는 지양:

* 실제 네트워크 호출
* 실제 알림 등록
* 테스트 간 상태 공유
* 순서에 의존하는 테스트
* 너무 많은 내용을 한 테스트에서 검증
* Mock이 실제 구현보다 복잡해지는 것
* UI Test 과다 작성

---

# Build / Test Command

## Unit Test

```bash
xcodebuild test -scheme Aran
```

필요 시 destination 명시:

```bash
xcodebuild test \
  -scheme Aran \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

# Portfolio Principles

테스트는 “많이 작성했다”보다 “왜 이 구조가 테스트 가능한가”를 보여주는 데 목적이 있다.

면접에서 설명할 포인트:

* Domain은 프레임워크 의존성이 없어 Unit Test가 쉽다.
* UseCase는 Repository Protocol에 의존해서 Mock 교체가 가능하다.
* ViewModel은 UI 없이 상태 변화를 검증할 수 있다.
* Repository는 DTO / Entity 분리를 통해 mapping 테스트가 가능하다.
* UI Test는 핵심 사용자 플로우만 검증한다.
