@testable import Aran
import XCTest

final class DrugRepositoryTests: XCTestCase {
    private var mockAPIClient: MockDrugAPIClient!
    private var mockApprovalAPIClient: MockDrugApprovalAPIClient!
    private var sut: DrugRepository!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockDrugAPIClient()
        mockApprovalAPIClient = MockDrugApprovalAPIClient()
        sut = DrugRepository(apiClient: mockAPIClient, approvalAPIClient: mockApprovalAPIClient)
    }

    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        mockApprovalAPIClient = nil
        super.tearDown()
    }

    func test_search_whenAPIReturnsItems_thenReturnsDrugs() async throws {
        // given
        let drugs = [makeDrug(name: "프로게스테론")]
        mockAPIClient.searchResult = .success(DrugSearchResult(drugs: drugs, totalCount: 1, pageNo: 1))

        // when
        let result = try await sut.search(keyword: "프로게스테론", pageNo: 1)

        // then
        XCTAssertEqual(result.drugs.count, 1)
        XCTAssertEqual(result.drugs.first?.itemName, "프로게스테론")
        XCTAssertEqual(result.totalCount, 1)
    }

    func test_search_whenAPIFails_thenThrowsAppError() async {
        // given
        mockAPIClient.searchResult = .failure(URLError(.notConnectedToInternet))

        // when / then
        do {
            _ = try await sut.search(keyword: "테스트", pageNo: 1)
            XCTFail("Expected AppError")
        } catch let error as AppError {
            if case .networkError = error {
                // success
            } else {
                XCTFail("Expected networkError, got \(error)")
            }
        } catch {
            XCTFail("Expected AppError, got \(error)")
        }
    }

    func test_search_whenAPIReturnsEmpty_thenReturnsEmptyArray() async throws {
        // given
        mockAPIClient.searchResult = .success(DrugSearchResult(drugs: [], totalCount: 0, pageNo: 1))

        // when
        let result = try await sut.search(keyword: "없는약", pageNo: 1)

        // then
        XCTAssertTrue(result.drugs.isEmpty)
        XCTAssertEqual(result.totalCount, 0)
    }

    func test_search_whenPrimaryAPIReturnsItems_thenDoesNotCallApprovalFallback() async throws {
        // given
        let drugs = [makeDrug(name: "프로게스테론")]
        mockAPIClient.searchResult = .success(DrugSearchResult(drugs: drugs, totalCount: 1, pageNo: 1))
        mockApprovalAPIClient.approvalInfos = [makeSolondoApprovalInfo()]

        // when
        let result = try await sut.search(keyword: "프로게스테론", pageNo: 1)

        // then
        XCTAssertEqual(result.drugs.map(\.itemSeq), ["200001234"])
        XCTAssertNil(mockApprovalAPIClient.receivedItemName)
    }

    func test_search_whenPrimaryAPIIsEmpty_thenReturnsApprovalFallbackResults() async throws {
        // given
        mockAPIClient.searchResult = .success(DrugSearchResult(drugs: [], totalCount: 0, pageNo: 1))
        mockApprovalAPIClient.approvalInfos = [makeSolondoApprovalInfo()]

        // when
        let result = try await sut.search(keyword: "소론도정", pageNo: 1)

        // then
        XCTAssertEqual(mockApprovalAPIClient.receivedItemName, "소론도정")
        XCTAssertEqual(result.totalCount, 1)
        XCTAssertEqual(result.drugs.first?.itemSeq, "199602982")
        XCTAssertEqual(result.drugs.first?.itemName, "소론도정(프레드니솔론)")
        XCTAssertEqual(result.drugs.first?.component, "Prednisolone")
        XCTAssertEqual(result.drugs.first?.approvalInfo?.ediCode, "642105020")
    }

    func test_search_whenPrimaryAPIIsEmptyAndApprovalFails_thenReturnsPrimaryEmptyResult() async throws {
        // given
        mockAPIClient.searchResult = .success(DrugSearchResult(drugs: [], totalCount: 0, pageNo: 1))
        mockApprovalAPIClient.shouldThrow = URLError(.notConnectedToInternet)

        // when
        let result = try await sut.search(keyword: "소론도정", pageNo: 1)

        // then
        XCTAssertTrue(result.drugs.isEmpty)
        XCTAssertEqual(result.totalCount, 0)
    }

    func test_enrich_whenApprovalMatchesItemSeq_thenUsesApprovalIngredient() async throws {
        // given
        let drug = makeDrug(name: "프로게스테론질정", component: "기존성분")
        mockApprovalAPIClient.approvalInfos = [DrugApprovalInfo(
            itemSeq: "200001234",
            itemName: "프로게스테론질정",
            entpName: "테스트제약",
            itemPermitDate: "20210101",
            barCode: "8801234567890",
            ediCode: "123456789",
            atcCode: "G03DA04",
            mainItemIngredient: "프로게스테론",
            productType: "[02450]부신호르몬제",
            specialtyPublic: "전문의약품",
            bigProductImageURL: "https://example.com/image",
            rareDrugYN: "N"
        )]

        // when
        let enrichedDrug = try await sut.enrich(drug)

        // then
        XCTAssertEqual(mockApprovalAPIClient.receivedItemName, "프로게스테론질정")
        XCTAssertEqual(enrichedDrug.component, "프로게스테론")
        XCTAssertEqual(enrichedDrug.approvalInfo?.barCode, "8801234567890")
    }

    func test_enrich_whenApprovalItemSeqDoesNotMatch_thenKeepsOriginalDrug() async throws {
        // given
        let drug = makeDrug(name: "프로게스테론질정", component: "기존성분")
        mockApprovalAPIClient.approvalInfos = [DrugApprovalInfo(
            itemSeq: "DIFFERENT",
            itemName: nil,
            entpName: nil,
            itemPermitDate: nil,
            barCode: nil,
            ediCode: nil,
            atcCode: nil,
            mainItemIngredient: "다른성분",
            productType: nil,
            specialtyPublic: nil,
            bigProductImageURL: nil,
            rareDrugYN: nil
        )]

        // when
        let enrichedDrug = try await sut.enrich(drug)

        // then
        XCTAssertEqual(enrichedDrug.component, "기존성분")
        XCTAssertNil(enrichedDrug.approvalInfo)
    }

    func test_enrich_whenApprovalAPIFails_thenKeepsOriginalDrug() async throws {
        // given
        let drug = makeDrug(name: "프로게스테론질정", component: "기존성분")
        mockApprovalAPIClient.shouldThrow = URLError(.notConnectedToInternet)

        // when
        let enrichedDrug = try await sut.enrich(drug)

        // then
        XCTAssertEqual(enrichedDrug.component, "기존성분")
        XCTAssertNil(enrichedDrug.approvalInfo)
    }
}

// MARK: - Helpers

private extension DrugRepositoryTests {
    func makeDrug(name: String, component: String? = nil) -> Drug {
        Drug(
            itemSeq: "200001234",
            itemName: name,
            entpName: "테스트제약",
            component: component,
            efcyQesitm: nil,
            useMethodQesitm: nil,
            atpnWarnQesitm: nil,
            atpnQesitm: nil,
            intrcQesitm: nil,
            seQesitm: nil,
            depositMethodQesitm: nil,
            itemImage: nil
        )
    }

    func makeSolondoApprovalInfo() -> DrugApprovalInfo {
        DrugApprovalInfo(
            itemSeq: "199602982",
            itemName: "소론도정(프레드니솔론)",
            entpName: "(주)유한양행",
            itemPermitDate: "19960423",
            barCode: nil,
            ediCode: "642105020",
            atcCode: nil,
            mainItemIngredient: "Prednisolone",
            productType: "[02450]부신호르몬제",
            specialtyPublic: "전문의약품",
            bigProductImageURL: "https://nedrug.mfds.go.kr/pbp/cmn/itemImageDownload/1OoAc19ns4C",
            rareDrugYN: nil
        )
    }
}
