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
5. Core UI Flow Test (Phase 2)

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

| 파일 | 테스트 수 | 상태 |
|------|----------|------|
| MedicationUseCaseTests | 8개 | ✅ 완료 |
| MedicationFormViewModelTests | 6개 | ✅ 완료 |
| CycleRecordUseCaseTests | 10개 | ✅ 완료 |
| SearchDrugUseCaseTests | 4개 | ✅ 완료 |
| HealthRecordUseCaseTests | 12개 | ✅ 완료 |
| MedicationNotificationUseCaseTests | 6개 | ✅ 완료 |
| DrugRepositoryTests | 3개 | ✅ 완료 |
| MedicationRepositoryTests | 3개 | ✅ 완료 |
| HealthRecordRepositoryTests | 4개 | ✅ 완료 |
| DrugMapperTests | 3개 | ✅ 완료 |
| MedicationMapperTests | 4개 | ✅ 완료 |
| DrugRouterTests | 4개 | ✅ 완료 |
| DrugAPIClientTests | 4개 | ✅ 완료 |

---

## UseCase Tests

### SearchDrugUseCase

검증 항목:
- 정상 검색 시 Drug 배열 반환
- 빈 검색어 입력 시 API 호출하지 않음
- 최소 글자 수 미달 시 validation error
- Repository error 전파
- 검색어 trim 처리

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
├── HealthRecordRepositoryTests.swift
└── CycleRecordRepositoryTests.swift
```

### DrugRepository

검증 항목:
- 검색 성공 시 DTO → Drug Entity 변환 확인
- APIClient 에러 → DomainError 변환
- 빈 배열 응답 처리
- Decoding 실패 처리

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

    func test_search_whenAPIFails_thenThrowsDomainError() async {
        // given
        let mockClient = MockDrugAPIClient()
        mockClient.result = .failure(URLError(.notConnectedToInternet))
        let repository = DefaultDrugRepository(apiClient: mockClient)

        // when / then
        do {
            _ = try await repository.search(keyword: "테스트")
            XCTFail("Expected error")
        } catch let error as DrugRepositoryError {
            XCTAssertEqual(error, .networkUnavailable)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_search_whenAPIReturnsEmpty_thenReturnsEmptyArray() async throws {
        // given
        let mockClient = MockDrugAPIClient()
        mockClient.result = .success([])
        let repository = DefaultDrugRepository(apiClient: mockClient)

        // when
        let drugs = try await repository.search(keyword: "없는약")

        // then
        XCTAssertTrue(drugs.isEmpty)
    }
}
```

### MedicationRepository (SwiftData)

검증 항목:
- 저장 후 fetchAll 시 포함 여부
- 비활성화 후 active 필터 조회
- 삭제 후 목록에서 제거 확인
- Schedule 포함 저장 및 조회

```swift
final class MedicationRepositoryTests: XCTestCase {

    var container: ModelContainer!
    var repository: DefaultMedicationRepository!

    override func setUp() async throws {
        // in-memory SwiftData container 사용
        let schema = Schema([MedicationModel.self, MedicationScheduleModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: config)
        repository = DefaultMedicationRepository(modelContext: ModelContext(container))
    }

    func test_save_whenMedicationIsValid_thenFetchAllContainsIt() async throws {
        // given
        let medication = Medication.stub(name: "프로게스테론")

        // when
        try await repository.save(medication)
        let result = try await repository.fetchAll()

        // then
        XCTAssertTrue(result.contains { $0.name == "프로게스테론" })
    }

    func test_fetchActive_whenMedicationIsInactive_thenExcludesIt() async throws {
        // given
        let active = Medication.stub(name: "활성약", isActive: true)
        let inactive = Medication.stub(name: "비활성약", isActive: false)
        try await repository.save(active)
        try await repository.save(inactive)

        // when
        let result = try await repository.fetchActive()

        // then
        XCTAssertTrue(result.contains { $0.name == "활성약" })
        XCTAssertFalse(result.contains { $0.name == "비활성약" })
    }

    func test_delete_whenMedicationExists_thenRemovedFromList() async throws {
        // given
        let medication = Medication.stub()
        try await repository.save(medication)

        // when
        try await repository.delete(medication)
        let result = try await repository.fetchAll()

        // then
        XCTAssertFalse(result.contains { $0.id == medication.id })
    }
}
```

### HealthRecordRepository (SwiftData)

검증 항목:
- 수치 저장 및 조회
- 항목별 필터 조회 (FSH, AMH 등)
- 날짜 내림차순 정렬
- 같은 항목 최신값 조회

---

## Mapper Tests

Mapper는 변환 로직이 명확하므로 단독 테스트 가능하다.

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
- HTML 태그 제거 (e약은요 API 응답에 포함될 수 있음)
- 빈 문자열 → nil 변환

```swift
final class DrugMapperTests: XCTestCase {

    func test_mapDTO_whenAllFieldsPresent_thenMapsCorrectly() {
        // given
        let dto = DrugItemDTO(
            itemSeq: "200001234",
            itemName: "프로게스테론질정",
            entpName: "한국의약품",
            efcyQesitm: "황체호르몬 보충",
            useMethodQesitm: "1일 2회 질 내 삽입",
            atpnWarnQesitm: nil,
            atpnQesitm: "임신 초기 사용 주의",
            seQesitm: nil,
            depositMethodQesitm: "실온 보관"
        )

        // when
        let drug = DrugMapper.toDomain(dto)

        // then
        XCTAssertEqual(drug.id, "200001234")
        XCTAssertEqual(drug.name, "프로게스테론질정")
        XCTAssertEqual(drug.manufacturer, "한국의약품")
        XCTAssertNil(drug.warning)
        XCTAssertNil(drug.sideEffect)
    }

    func test_mapDTO_whenOptionalFieldsAreNil_thenEntityHasNilValues() {
        // given
        let dto = DrugItemDTO.stub(efcyQesitm: nil, useMethodQesitm: nil)

        // when
        let drug = DrugMapper.toDomain(dto)

        // then
        XCTAssertNil(drug.efficacy)
        XCTAssertNil(drug.useMethod)
    }

    func test_mapDTO_whenFieldContainsHTMLTags_thenStripsHTML() {
        // given
        let dto = DrugItemDTO.stub(efcyQesitm: "<p>황체호르몬 <b>보충</b></p>")

        // when
        let drug = DrugMapper.toDomain(dto)

        // then
        XCTAssertEqual(drug.efficacy, "황체호르몬 보충")
    }
}
```

### MedicationMapper

검증 항목:
- Medication → MedicationModel 변환
- MedicationModel → Medication 변환
- Schedule 포함 변환
- isActive 상태 보존

---

## Network Layer Tests

Network 테스트는 **Router**와 **APIClient** 두 레벨로 나눈다.
실제 HTTP 호출은 하지 않는다.

### 테스트 파일 위치

```
AranTests/Data/Network/
├── DrugRouterTests.swift
└── DrugAPIClientTests.swift
```

### DrugRouter Tests

Router는 `URLRequest`를 올바르게 생성하는지 검증한다.

검증 항목:
- URL 구성 정확성 (baseURL + path)
- 필수 query parameter 포함 여부 (serviceKey, type=json)
- keyword 인코딩 처리
- pageNo 파라미터 반영
- HTTP method (GET)

```swift
final class DrugRouterTests: XCTestCase {

    func test_searchRouter_whenKeywordProvided_thenURLContainsKeyword() throws {
        // given
        let router = DrugRouter.search(keyword: "프로게스테론", pageNo: 1)

        // when
        let request = try router.asURLRequest()

        // then
        let urlString = request.url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("itemName"))
        XCTAssertTrue(urlString.contains("프로게스테론".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))
    }

    func test_searchRouter_whenBuilt_thenHTTPMethodIsGET() throws {
        // given
        let router = DrugRouter.search(keyword: "테스트", pageNo: 1)

        // when
        let request = try router.asURLRequest()

        // then
        XCTAssertEqual(request.httpMethod, "GET")
    }

    func test_searchRouter_whenBuilt_thenContainsRequiredParameters() throws {
        // given
        let router = DrugRouter.search(keyword: "테스트", pageNo: 2)

        // when
        let request = try router.asURLRequest()
        let urlString = request.url?.absoluteString ?? ""

        // then
        XCTAssertTrue(urlString.contains("pageNo=2"))
        XCTAssertTrue(urlString.contains("type=json"))
        XCTAssertTrue(urlString.contains("numOfRows"))
    }

    func test_searchRouter_whenBuilt_thenBaseURLIsCorrect() throws {
        // given
        let router = DrugRouter.search(keyword: "테스트", pageNo: 1)

        // when
        let request = try router.asURLRequest()

        // then
        XCTAssertTrue(request.url?.host == "apis.data.go.kr")
        XCTAssertTrue(request.url?.path.contains("DrbEasyDrugInfoService") == true)
    }
}
```

### DrugAPIClient Tests

APIClient는 **MockURLProtocol**을 사용해 실제 네트워크 없이 테스트한다.

검증 항목:
- 정상 JSON 응답 → DTO 배열 반환
- 빈 응답 배열 처리
- HTTP 4xx / 5xx → 에러 throw
- JSON decoding 실패 처리
- 네트워크 연결 실패 처리

```swift
// MockURLProtocol 설정
final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// APIClient 테스트
final class DrugAPIClientTests: XCTestCase {

    var session: Session!
    var apiClient: DrugAPIClient!

    override func setUp() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = Session(configuration: configuration)
        apiClient = DrugAPIClient(session: session)
    }

    func test_search_whenValidResponse_thenReturnsDTOArray() async throws {
        // given
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://apis.data.go.kr")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let json = """
            {
                "body": {
                    "items": [
                        { "itemSeq": "123", "itemName": "프로게스테론", "entpName": "한국의약품" }
                    ],
                    "totalCount": 1
                }
            }
            """.data(using: .utf8)!
            return (response, json)
        }

        // when
        let result = try await apiClient.search(keyword: "프로게스테론", pageNo: 1)

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.itemName, "프로게스테론")
    }

    func test_search_whenServerReturns500_thenThrowsNetworkError() async {
        // given
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://apis.data.go.kr")!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        // when / then
        do {
            _ = try await apiClient.search(keyword: "테스트", pageNo: 1)
            XCTFail("Expected network error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func test_search_whenResponseIsEmpty_thenReturnsEmptyArray() async throws {
        // given
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://apis.data.go.kr")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let json = """
            { "body": { "items": [], "totalCount": 0 } }
            """.data(using: .utf8)!
            return (response, json)
        }

        // when
        let result = try await apiClient.search(keyword: "없는약", pageNo: 1)

        // then
        XCTAssertTrue(result.isEmpty)
    }

    func test_search_whenDecodingFails_thenThrowsDecodingError() async {
        // given
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://apis.data.go.kr")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let malformedJSON = "{ invalid json }".data(using: .utf8)!
            return (response, malformedJSON)
        }

        // when / then
        do {
            _ = try await apiClient.search(keyword: "테스트", pageNo: 1)
            XCTFail("Expected decoding error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
```

---

## Mock 전략

### Mock 파일 위치

```
AranTests/Mocks/
├── MockDrugRepository.swift
├── MockMedicationRepository.swift
├── MockHealthRecordRepository.swift
├── MockCycleRecordRepository.swift
├── MockNotificationRepository.swift
├── MockDrugAPIClient.swift          ← Network 테스트용
└── MockURLProtocol.swift            ← URLSession 레벨 Mock
```

### Mock 작성 규칙

```swift
final class MockDrugRepository: DrugRepositoryProtocol {
    var searchResult: Result<[Drug], Error> = .success([])
    private(set) var receivedKeyword: String?
    private(set) var searchCallCount = 0

    func search(keyword: String) async throws -> [Drug] {
        searchCallCount += 1
        receivedKeyword = keyword
        return try searchResult.get()
    }
}

final class MockDrugAPIClient: DrugAPIClientProtocol {
    var result: Result<[DrugItemDTO], Error> = .success([])
    private(set) var callCount = 0

    func search(keyword: String, pageNo: Int) async throws -> [DrugItemDTO] {
        callCount += 1
        return try result.get()
    }
}
```

- `Result` 타입으로 success / failure 모두 지원
- `private(set)` 으로 호출 검증 가능
- Test Target에만 포함 (Production 코드 금지)

---

## Fixture 정책

반복 테스트 데이터는 Fixture로 분리한다.

```
AranTests/Fixtures/
├── DrugFixture.swift
├── MedicationFixture.swift
├── HealthRecordFixture.swift
└── DTOFixture.swift           ← DTO stub 추가
```

```swift
// DTOFixture.swift
extension DrugItemDTO {
    static func stub(
        itemSeq: String = "200001234",
        itemName: String = "테스트약",
        entpName: String = "테스트제약",
        efcyQesitm: String? = "테스트 효능"
    ) -> DrugItemDTO {
        DrugItemDTO(
            itemSeq: itemSeq,
            itemName: itemName,
            entpName: entpName,
            efcyQesitm: efcyQesitm,
            useMethodQesitm: nil,
            atpnWarnQesitm: nil,
            atpnQesitm: nil,
            seQesitm: nil,
            depositMethodQesitm: nil
        )
    }
}
```

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
| UI Tests | 핵심 플로우 5개 |

숫자보다 중요한 것은 **핵심 비즈니스 로직이 독립적으로 테스트 가능한 구조**인지다.

---

## 빌드 / 테스트 명령어

```bash
# 전체 테스트
xcodebuild test -scheme Aran

# Simulator 지정
xcodebuild test \
  -scheme Aran \
  -destination 'platform=iOS Simulator,name=iPhone 16'
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
- Repository는 APIClient를 Protocol로 추상화해서 MockURLProtocol 없이도 테스트 가능하다.
- Router 테스트로 URL 구성 오류를 빌드 전에 잡을 수 있다.
- Mapper 테스트로 API 필드 변경에 대한 회귀를 방지한다.
- SwiftData Repository는 in-memory container로 격리 테스트한다.
