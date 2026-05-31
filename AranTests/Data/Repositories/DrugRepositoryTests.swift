import XCTest
@testable import Aran

final class DrugRepositoryTests: XCTestCase {
    private func makeDrug(
        itemSeq: String,
        itemName: String = "테스트약",
        approvalInfo: DrugApprovalInfo? = nil
    ) -> Drug {
        Drug(
            itemSeq: itemSeq,
            itemName: itemName,
            entpName: "테스트제약",
            efcyQesitm: nil,
            useMethodQesitm: nil,
            atpnWarnQesitm: nil,
            atpnQesitm: nil,
            intrcQesitm: nil,
            seQesitm: nil,
            depositMethodQesitm: nil,
            itemImage: nil,
            approvalInfo: approvalInfo
        )
    }

    private func makeApprovalInfo(itemSeq: String, ingredient: String?) -> DrugApprovalInfo {
        DrugApprovalInfo(
            itemSeq: itemSeq,
            itemName: "테스트약",
            entpName: "테스트제약",
            itemPermitDate: nil,
            barCode: nil,
            ediCode: nil,
            atcCode: nil,
            mainItemIngredient: ingredient,
            productType: nil,
            specialtyPublic: "전문의약품",
            bigProductImageURL: nil,
            rareDrugYN: nil
        )
    }

    private func makeSUT(
        easyResult: DrugSearchResult? = nil,
        easyError: Error? = nil,
        prescriptionResult: DrugSearchResult? = nil,
        prescriptionError: Error? = nil,
        approvalInfos: [DrugApprovalInfo] = []
    ) -> (DrugRepository, MockDrugAPIClient, MockDrugApprovalAPIClient) {
        let apiClient = MockDrugAPIClient()
        if let easyError {
            apiClient.searchResult = .failure(easyError)
        } else if let easyResult {
            apiClient.searchResult = .success(easyResult)
        }
        let approvalClient = MockDrugApprovalAPIClient()
        approvalClient.searchResult = prescriptionResult
        approvalClient.error = prescriptionError
        approvalClient.infos = approvalInfos
        let sut = DrugRepository(apiClient: apiClient, approvalAPIClient: approvalClient)
        return (sut, apiClient, approvalClient)
    }

    func test_search_returnsPrescriptionResult_whenPrescriptionHasData() async throws {
        let drugs = [makeDrug(itemSeq: "1"), makeDrug(itemSeq: "2")]
        let (sut, _, _) = makeSUT(prescriptionResult: DrugSearchResult(drugs: drugs, totalCount: 2, pageNo: 1))

        let result = try await sut.search(keyword: "고나도트로핀", pageNo: 1)

        XCTAssertEqual(result.drugs.count, 2)
        XCTAssertEqual(result.totalCount, 2)
    }

    func test_search_fallsBackToEasyDrug_whenPrescriptionEmpty() async throws {
        let easyDrugs = [makeDrug(itemSeq: "100", itemName: "타이레놀")]
        let (sut, _, _) = makeSUT(
            easyResult: DrugSearchResult(drugs: easyDrugs, totalCount: 1, pageNo: 1),
            prescriptionResult: DrugSearchResult(drugs: [], totalCount: 0, pageNo: 1)
        )

        let result = try await sut.search(keyword: "타이레놀", pageNo: 1)

        XCTAssertEqual(result.drugs.count, 1)
        XCTAssertEqual(result.drugs.first?.itemName, "타이레놀")
    }

    func test_search_fallsBackToEasyDrug_whenPrescriptionThrows() async throws {
        let easyDrugs = [makeDrug(itemSeq: "100", itemName: "타이레놀")]
        let (sut, _, _) = makeSUT(
            easyResult: DrugSearchResult(drugs: easyDrugs, totalCount: 1, pageNo: 1),
            prescriptionError: AppError.networkError(URLError(.timedOut))
        )

        let result = try await sut.search(keyword: "타이레놀", pageNo: 1)

        XCTAssertEqual(result.drugs.first?.itemName, "타이레놀")
    }

    func test_search_doesNotFallback_whenNotFirstPage() async throws {
        let (sut, _, _) = makeSUT(
            easyResult: DrugSearchResult(drugs: [makeDrug(itemSeq: "100")], totalCount: 1, pageNo: 2),
            prescriptionResult: DrugSearchResult(drugs: [], totalCount: 0, pageNo: 2)
        )

        let result = try await sut.search(keyword: "타이레놀", pageNo: 2)

        XCTAssertTrue(result.drugs.isEmpty)
    }

    func test_enrich_addsApprovalInfo_whenDrugHasNoApprovalInfo() async throws {
        let info = makeApprovalInfo(itemSeq: "1", ingredient: "테스트성분")
        let (sut, _, _) = makeSUT(approvalInfos: [info])

        let enriched = try await sut.enrich(makeDrug(itemSeq: "1"))

        XCTAssertEqual(enriched.approvalInfo?.mainItemIngredient, "테스트성분")
    }

    func test_enrich_skips_whenDrugAlreadyHasApprovalInfo() async throws {
        let existing = makeApprovalInfo(itemSeq: "1", ingredient: "기존성분")
        let (sut, _, approvalClient) = makeSUT(approvalInfos: [makeApprovalInfo(itemSeq: "1", ingredient: "새성분")])

        let enriched = try await sut.enrich(makeDrug(itemSeq: "1", approvalInfo: existing))

        XCTAssertEqual(enriched.approvalInfo?.mainItemIngredient, "기존성분")
        XCTAssertNil(approvalClient.capturedItemName)
    }
}
