import XCTest
@testable import Aran
import AranDomain

final class DrugRepositoryTests: XCTestCase {
    private func makeDrug(
        itemSeq: String,
        itemName: String = "테스트약",
        efcyQesitm: String? = nil,
        approvalInfo: DrugApprovalInfo? = nil
    ) -> Drug {
        Drug(
            itemSeq: itemSeq,
            itemName: itemName,
            entpName: "테스트제약",
            efcyQesitm: efcyQesitm,
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

    private func makeApprovalInfo(
        itemSeq: String,
        ingredient: String?,
        specialtyPublic: String = "전문의약품"
    ) -> DrugApprovalInfo {
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
            specialtyPublic: specialtyPublic,
            bigProductImageURL: nil,
            rareDrugYN: nil
        )
    }

    private func makeSUT(
        easyResult: DrugSearchResult? = nil,
        easyError: Error? = nil,
        prescriptionResult: DrugSearchResult? = nil,
        prescriptionError: Error? = nil,
        detailDrug: Drug? = nil
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
        approvalClient.detailDrug = detailDrug
        let sut = DrugRepository(apiClient: apiClient, approvalAPIClient: approvalClient)
        return (sut, apiClient, approvalClient)
    }

    func test_search_returnsPrescriptionResult_whenPrescriptionHasData() async throws {
        let drugs = [
            makeDrug(itemSeq: "1", approvalInfo: makeApprovalInfo(itemSeq: "1", ingredient: nil)),
            makeDrug(itemSeq: "2", approvalInfo: makeApprovalInfo(itemSeq: "2", ingredient: nil)),
        ]
        let (sut, easyClient, _) = makeSUT(
            prescriptionResult: DrugSearchResult(drugs: drugs, totalCount: 2, pageNo: 1)
        )

        let result = try await sut.search(keyword: "고나도트로핀", pageNo: 1)

        XCTAssertEqual(result.drugs.count, 2)
        XCTAssertEqual(result.totalCount, 2)
        XCTAssertEqual(easyClient.searchCallCount, 0)
    }

    func test_search_returnsApprovalResult_whenApprovalResultHasOnlyGeneralDrug() async throws {
        let generalDrug = makeDrug(
            itemSeq: "1",
            approvalInfo: makeApprovalInfo(itemSeq: "1", ingredient: nil, specialtyPublic: "일반의약품")
        )
        let easyDrug = makeDrug(itemSeq: "100", itemName: "타이레놀")
        let (sut, easyClient, _) = makeSUT(
            easyResult: DrugSearchResult(drugs: [easyDrug], totalCount: 1, pageNo: 1),
            prescriptionResult: DrugSearchResult(drugs: [generalDrug], totalCount: 1, pageNo: 1)
        )

        let result = try await sut.search(keyword: "타이레놀", pageNo: 1)

        XCTAssertEqual(result.drugs.map(\.itemSeq), ["1"])
        XCTAssertEqual(easyClient.searchCallCount, 0)
    }

    func test_search_returnsAllApprovalDrugs_whenApprovalResultIsMixed() async throws {
        let prescriptionDrug = makeDrug(
            itemSeq: "1",
            approvalInfo: makeApprovalInfo(itemSeq: "1", ingredient: nil)
        )
        let generalDrug = makeDrug(
            itemSeq: "2",
            approvalInfo: makeApprovalInfo(itemSeq: "2", ingredient: nil, specialtyPublic: "일반의약품")
        )
        let (sut, easyClient, _) = makeSUT(
            prescriptionResult: DrugSearchResult(drugs: [prescriptionDrug, generalDrug], totalCount: 2, pageNo: 1)
        )

        let result = try await sut.search(keyword: "테스트약", pageNo: 1)

        XCTAssertEqual(result.drugs.map(\.itemSeq), ["1", "2"])
        XCTAssertEqual(result.totalCount, 2)
        XCTAssertEqual(easyClient.searchCallCount, 0)
    }

    func test_search_fallsBackToEasyDrug_whenPrescriptionEmpty() async throws {
        let easyDrugs = [makeDrug(itemSeq: "100", itemName: "타이레놀")]
        let (sut, _, _) = makeSUT(
            easyResult: DrugSearchResult(drugs: easyDrugs, totalCount: 1, pageNo: 1),
            prescriptionResult: DrugSearchResult(drugs: [], totalCount: 0, pageNo: 1)
        )

        let result = try await sut.search(keyword: "타이레놀", pageNo: 1)

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
        let (sut, easyClient, _) = makeSUT(
            easyResult: DrugSearchResult(drugs: [makeDrug(itemSeq: "100")], totalCount: 1, pageNo: 2),
            prescriptionResult: DrugSearchResult(drugs: [], totalCount: 0, pageNo: 2)
        )

        let result = try await sut.search(keyword: "타이레놀", pageNo: 2)

        XCTAssertTrue(result.drugs.isEmpty)
        XCTAssertEqual(easyClient.searchCallCount, 0)
    }

    func test_enrich_fillsEfficacyAndApprovalInfo_fromDetail() async throws {
        let detail = makeDrug(
            itemSeq: "1",
            efcyQesitm: "상세 효능",
            approvalInfo: makeApprovalInfo(itemSeq: "1", ingredient: "테스트성분")
        )
        let (sut, _, approvalClient) = makeSUT(detailDrug: detail)

        let enriched = try await sut.enrich(makeDrug(itemSeq: "1"))

        XCTAssertEqual(enriched.efcyQesitm, "상세 효능")
        XCTAssertEqual(enriched.approvalInfo?.mainItemIngredient, "테스트성분")
        XCTAssertEqual(approvalClient.capturedItemSeq, "1")
    }

    func test_enrich_keepsExistingEfficacy_whenAlreadyPresent() async throws {
        let detail = makeDrug(itemSeq: "1", efcyQesitm: "상세 효능")
        let (sut, _, _) = makeSUT(detailDrug: detail)

        let enriched = try await sut.enrich(makeDrug(itemSeq: "1", efcyQesitm: "기존 효능"))

        XCTAssertEqual(enriched.efcyQesitm, "기존 효능")
    }

    func test_enrich_returnsOriginal_whenDetailIsNil() async throws {
        let (sut, _, approvalClient) = makeSUT(detailDrug: nil)

        let enriched = try await sut.enrich(makeDrug(itemSeq: "1", efcyQesitm: "기존 효능"))

        XCTAssertEqual(enriched.efcyQesitm, "기존 효능")
        XCTAssertEqual(approvalClient.capturedItemSeq, "1")
    }

    func test_enrich_returnsOriginal_whenDetailThrows() async throws {
        let (sut, _, _) = makeSUT(prescriptionError: AppError.networkError(URLError(.timedOut)))

        let enriched = try await sut.enrich(makeDrug(itemSeq: "1", efcyQesitm: "기존 효능"))

        XCTAssertEqual(enriched.efcyQesitm, "기존 효능")
    }
}
