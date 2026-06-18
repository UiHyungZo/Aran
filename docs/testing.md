# Testing

## Goal

Aran의 테스트 전략은 Clean Architecture를 선택한 이유를 증명하는 것이다.

목표:
- 핵심 비즈니스 로직을 UI 없이 검증한다.
- 네트워크, DB, 알림 의존성 없이 UseCase를 테스트한다.
- ViewModel의 상태 변화와 입력 검증을 테스트한다.
- Repository 구현의 Mapping / Error Handling을 검증한다.
- Network Layer의 Request 구성과 Response 처리를 검증한다.
- 포트폴리오에서 "테스트 가능한 구조"를 설명할 수 있게 한다.

---

## Test Targets

```
Aran
├── Application
├── Presentation
├── Domain
├── Data
└── Infrastructure

AranTests
├── Domain/
├── Presentation/
├── Data/
│   ├── Repositories/
│   ├── Mappers/
│   └── Network/
└── Mocks/

AranUITests
└── Flows/
```

규칙:
- Unit Test는 `AranTests`에 작성한다.
- UI Test는 `AranUITests`에 작성한다.
- Mock 객체는 앱 소스가 아닌 테스트 타겟 내부에 둔다.

---

## Test Priority

1. UseCase Unit Test
2. ViewModel Unit Test
3. Repository / Mapper Test
4. Network Layer Test
5. Core UI Flow Test

---

## Test Style

```swift
func test_searchDrug_whenKeywordIsEmpty_thenThrowsError() async {
    // given

    // when

    // then
}
```

규칙:
- `given / when / then` 구조를 따른다.
- 테스트 이름 패턴: `test_기능_when상황_then결과`
- 하나의 테스트는 하나의 동작만 검증한다.
- 테스트 내부에서 실제 네트워크, 알림, DB에 의존하지 않는다.

---

## 현재 테스트 현황

### AranDomain (swift test — 시뮬레이터 불필요)

`Packages/AranDomain/Tests/AranDomainTests/UseCases/`

| 파일 | 상태 |
|------|------|
| MedicationUseCaseTests | ✅ |
| MedicationLogUseCaseTests | ✅ |
| MedicationNotificationUseCaseTests | ✅ |
| HealthRecordUseCaseTests | ✅ |
| CycleRecordUseCaseTests | ✅ |
| TransferRecordUseCaseTests | ✅ |
| SearchDrugUseCaseTests | ✅ |
| FavoriteDrugUseCaseTests | ✅ |
| RecentDrugSearchUseCaseTests | ✅ |
| DiaryEntryUseCaseTests | ✅ |
| HospitalVisitUseCaseTests | ✅ |
| MenstrualCycleUseCaseTests | ✅ |
| PGTRecordUseCaseTests | ✅ |

### AranTests (xcodebuild test)

| 분류 | 파일 | 상태 |
|------|------|------|
| Mapper | DrugMapper, MedicationMapper, CycleRecordMapper, DiaryEntryMapper, DrugApprovalMapper, FavoriteDrugMapper, HealthRecordMapper, HospitalVisitMapper, MedicationLogMapper, MenstrualCycleMapper, PGTRecordMapper, RecentDrugSearchMapper, TransferRecordMapper (13개) | ✅ |
| Repository | CycleRecord, DiaryEntry, Drug, FavoriteDrug, HealthRecord, HospitalVisit, MedicationLog, Medication, MenstrualCycle, PGTRecord, RecentDrugSearch, TransferRecord (12개) | ✅ |
| Network | DrugAPIClient, DrugRouter, DrugApprovalRouter, DocDataXMLParser (4개) | ✅ |
| ViewModel | CalendarViewModel, DrugInfoViewModel, ExamHistoryViewModel, HealthRecordFormViewModel, HealthRecordViewModel, MedicationFormViewModel, MedicationViewModel, ProcedureRecordViewModel (8개) | ✅ |
| UITest | CalendarFlow, DrugSearchFlow, HealthRecordFlow, MedicationFlow, ProcedureRecordFlow (5개) | ✅ |

---

## UseCase Tests

### SearchDrugUseCase

검증 항목:
- 정상 검색 시 Drug 배열 반환
- 빈 검색어 입력 시 API 호출하지 않음
- 최소 글자 수 미달 시 validation error
- Repository error 전파

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

### MedicationNotificationUseCase

검증 항목:
- 복용 시간별 알림 등록
- 알림 수정 시 기존 알림 취소 → 새 알림 재등록
- 약 비활성화 시 관련 알림 전체 취소
- notificationId 안정성 유지

### MedicationLogUseCase ← v14 신규

검증 항목:
- 복용 체크 저장 (isTaken = true)
- 날짜별 복용 로그 조회
- 체크 토글 (true → false, false → true)
- 같은 날짜·약 중복 저장 방지

```swift
func test_toggleLog_whenNotTaken_thenSavesAsTaken() async throws {
    // given
    let repository = MockMedicationLogRepository()
    let useCase = MedicationLogUseCase(repository: repository)
    let medication = Medication.stub()

    // when
    try await useCase.toggle(medicationId: medication.id, date: Date())

    // then
    let log = try await repository.fetch(medicationId: medication.id, date: Date())
    XCTAssertTrue(log?.isTaken ?? false)
}
```

### MenstrualCycleUseCase ← v14 신규

검증 항목:
- 생리 시작일 저장
- 배란 예정일 계산 (startDate + cycleLength - 14)
- 주기 수정
- 기본 주기 28일 적용

```swift
func test_calculateOvulation_whenCycleLengthIs28_thenOvulationIsDay14() async throws {
    // given
    let repository = MockMenstrualCycleRepository()
    let useCase = MenstrualCycleUseCase(repository: repository)
    let startDate = Calendar.current.startOfDay(for: Date())

    // when
    let ovulation = useCase.calculateOvulationDate(startDate: startDate, cycleLength: 28)

    // then
    let expected = Calendar.current.date(byAdding: .day, value: 14, to: startDate)
    XCTAssertEqual(ovulation, expected)
}
```

### CycleRecordUseCase

검증 항목:
- 채취 기록 저장
- 차수별 기록 조회
- 이식 기록 추가 및 결과 업데이트
- 날짜 기준 조회

### HealthRecordUseCase

검증 항목:
- 검사 수치 저장
- 항목별 최신값 조회
- 날짜순 정렬
- 이전 수치 대비 증감 계산
- 커스텀 항목 저장 (String type)
- 잘못된 수치 입력 처리

---

## Repository Tests

Repository 테스트는 **DTO → Entity 변환**, **에러 변환**, **Storage 동작**을 검증한다.
실제 네트워크 / SwiftData 호출은 하지 않는다.

### 테스트 파일 위치

```
AranTests/Data/Repositories/
├── DrugRepositoryTests.swift
├── MedicationRepositoryTests.swift
├── MedicationLogRepositoryTests.swift      ← v14 신규
├── HealthRecordRepositoryTests.swift
├── CycleRecordRepositoryTests.swift
├── TransferRecordRepositoryTests.swift
├── HospitalVisitRepositoryTests.swift      ← v14 신규 (visitTypes 복수)
└── MenstrualCycleRepositoryTests.swift     ← v14 신규
```

### MedicationLogRepository ← v14 신규

검증 항목:
- 날짜별 복용 로그 저장
- medicationId + logDate 기준 단건 조회
- isTaken 토글
- Medication 삭제 시 연관 로그 함께 삭제

```swift
final class MedicationLogRepositoryTests: XCTestCase {

    func test_save_whenLogSaved_thenFetchReturnsIt() async throws {
        // given (in-memory SwiftData)
        let log = MedicationLog(
            id: UUID(),
            medicationId: UUID(),
            logDate: Calendar.current.startOfDay(for: Date()),
            isTaken: true
        )

        // when
        try await repository.save(log)
        let result = try await repository.fetch(medicationId: log.medicationId, date: log.logDate)

        // then
        XCTAssertEqual(result?.isTaken, true)
    }
}
```

### HospitalVisitRepository ← v14 신규 (visitTypes 배열)

검증 항목:
- visitTypes 배열 저장 및 조회
- 복수 종류(내원+채혈) 동시 저장
- 날짜 범위 조회
- 수정/삭제

### DrugRepository

검증 항목:
- 검색 성공 시 DTO → Drug Entity 변환 확인
- APIClient 에러 → DomainError 변환
- 빈 배열 응답 처리

```swift
final class DrugRepositoryTests: XCTestCase {

    func test_search_whenAPIReturnsItems_thenReturnsMappedDrugs() async throws {
        // given
        let mockClient = MockDrugAPIClient()
        mockClient.result = .success([DrugItemDTO.stub(itemName: "프로게스테론")])
        let repository = DefaultDrugRepository(apiClient: mockClient)

        // when
        let drugs = try await repository.search(keyword: "프로게스테론")

        // then
        XCTAssertEqual(drugs.count, 1)
        XCTAssertEqual(drugs.first?.name, "프로게스테론")
    }
}
```

### MedicationRepository (SwiftData)

검증 항목:
- 저장 후 fetchAll 시 포함 여부
- 비활성화 후 active 필터 조회
- 삭제 후 목록에서 제거 확인
- Schedule 포함 저장 및 조회

---

## Mapper Tests

### 테스트 파일 위치

```
AranTests/Data/Mappers/
├── DrugMapperTests.swift
└── MedicationMapperTests.swift
```

### DrugMapper

검증 항목:
- 모든 필드 정상 매핑
- optional 필드 nil 처리
- HTML 태그 제거
- 빈 문자열 → nil 변환

### MedicationMapper

검증 항목:
- Medication → MedicationModel 변환
- MedicationModel → Medication 변환
- Schedule 포함 변환
- isActive 상태 보존

---

## Network Layer Tests

### 테스트 파일 위치

```
AranTests/Data/Network/
├── DrugRouterTests.swift
└── DrugAPIClientTests.swift
```

### DrugRouter Tests

검증 항목:
- URL 구성 정확성 (baseURL + path)
- 필수 query parameter 포함 여부 (serviceKey, type=json)
- keyword 인코딩 처리
- pageNo 파라미터 반영
- HTTP method (GET)

### DrugAPIClient Tests

검증 항목:
- 정상 JSON 응답 → DTO 배열 반환
- 빈 응답 배열 처리
- HTTP 4xx / 5xx → 에러 throw
- JSON decoding 실패 처리
- 네트워크 연결 실패 처리

---

## ViewModel Tests

### 테스트 파일 위치

```
AranTests/Presentation/ViewModels/
├── MedicationFormViewModelTests.swift      ✅ 완료
├── CalendarViewModelTests.swift            ❌ 미구현
├── DrugInfoViewModelTests.swift            ❌ 미구현
├── ExamHistoryViewModelTests.swift         ❌ 미구현
├── HealthRecordFormViewModelTests.swift    ❌ 미구현
├── HealthRecordViewModelTests.swift        ❌ 미구현
└── PGTFormViewModelTests.swift             ❌ 미구현
```

### CalendarViewModel

검증 항목:
- @Published 날짜 선택 상태 변화
- 도트 데이터 바인딩 (MedicationLog 포함)
- 복용 약 체크 토글 → MedicationLog 저장

### MedicationFormViewModel (RxSwift)

검증 항목:
- 입력 유효성 검사
- 저장 버튼 활성화 조건
- 수정 모드 초기값 바인딩

---

## UI Tests

### 테스트 시나리오 (AranUITests/Flows/)

| 플로우 | 시나리오 |
|--------|---------|
| 캘린더 탭 플로우 | 날짜 탭 → 1단계 시트 → 감정 일기 탭 → 2단계 시트 → 저장 → 1단계 시트 반영 확인 |
| 복용 약 체크 플로우 | 캘린더 1단계 시트 → 약 체크 → 체크 상태 저장 확인 |
| 약 등록/수정 플로우 | 약/주사 탭 → + → 약 검색 → 등록 → 셀 탭 → 수정 → 목록 반영 확인 |
| 약 검색 플로우 | 약 정보 탭 → 검색 → 결과 → 상세 → 이 약 추가하기 → 등록 폼 확인 |
| 채취/이식 입력 플로우 | 시술 기록 탭 → + → 개수·등급 입력 → 저장 → 차수 카드 반영 확인 |
| 검사 수치 입력 플로우 | 검사 탭 → + → 항목·수치 입력 → 저장 → 목록 증감 표시 확인 |

---

## Mock 전략

### Mock 파일 위치

```
AranTests/Mocks/
├── MockDrugRepository.swift
├── MockMedicationRepository.swift
├── MockMedicationLogRepository.swift       ← v14 신규
├── MockHealthRecordRepository.swift
├── MockCycleRecordRepository.swift
├── MockTransferRecordRepository.swift
├── MockHospitalVisitRepository.swift       ← v14 신규
├── MockMenstrualCycleRepository.swift      ← v14 신규
├── MockNotificationRepository.swift
├── MockDrugAPIClient.swift
└── MockURLProtocol.swift
```

### Mock 작성 규칙

```swift
final class MockMedicationLogRepository: MedicationLogRepositoryProtocol {
    var savedLogs: [MedicationLog] = []
    private(set) var saveCallCount = 0

    func save(_ log: MedicationLog) async throws {
        saveCallCount += 1
        savedLogs.append(log)
    }

    func fetch(medicationId: UUID, date: Date) async throws -> MedicationLog? {
        savedLogs.first {
            $0.medicationId == medicationId &&
            Calendar.current.isDate($0.logDate, inSameDayAs: date)
        }
    }
}
```

- `Result` 타입으로 success / failure 모두 지원
- `private(set)` 으로 호출 검증 가능
- Test Target에만 포함 (Production 코드 금지)

---

## Coverage 목표

| Layer | 목표 |
|-------|------|
| Domain / UseCases | 80%+ |
| Data / Repositories | 60%+ |
| Data / Mappers | 70%+ |
| Data / Network (Router) | 70%+ |
| Data / Network (APIClient) | 60%+ |
| Presentation / ViewModels | 50%+ |
| UI Tests | 핵심 플로우 6개 |

숫자보다 중요한 것은 **핵심 비즈니스 로직이 독립적으로 테스트 가능한 구조**인지다.

---

## 빌드 / 테스트 명령어

```bash
# UseCase 단위 테스트 (시뮬레이터 불필요)
swift test --package-path Packages/AranDomain

# 전체 단위 테스트
xcodebuild test -scheme AranTests \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

---

## Anti-patterns

금지:
- 실제 네트워크 호출
- 실제 알림 등록
- 실제 SwiftData 파일 기반 container (in-memory 사용)
- 테스트 간 상태 공유
- 순서에 의존하는 테스트
- 한 테스트에서 여러 동작 동시 검증
- Mock이 실제 구현보다 복잡해지는 것

---

## 포트폴리오 어필 포인트

면접에서 설명할 포인트:
- Domain은 프레임워크 의존성이 없어 Unit Test가 간단하다.
- UseCase는 Repository Protocol에 의존하므로 Mock 교체가 가능하다.
- Repository는 APIClient를 Protocol로 추상화해서 테스트 가능하다.
- Router 테스트로 URL 구성 오류를 빌드 전에 잡을 수 있다.
- Mapper 테스트로 API 필드 변경에 대한 회귀를 방지한다.
- SwiftData Repository는 in-memory container로 격리 테스트한다.
- MedicationLog 분리로 날짜별 복용 체크를 독립적으로 테스트한다.
