@testable import Aran
import XCTest

@MainActor
final class DrugInfoViewModelTests: XCTestCase {
    private var searchUseCase: MockSearchDrugUseCase!
    private var favoriteRepository: MockFavoriteDrugRepository!
    private var sut: DrugInfoViewModel!

    override func setUp() {
        super.setUp()
        searchUseCase = MockSearchDrugUseCase()
        favoriteRepository = MockFavoriteDrugRepository()
        sut = DrugInfoViewModel(
            searchDrugUseCase: searchUseCase,
            favoriteDrugUseCase: FavoriteDrugUseCase(repository: favoriteRepository)
        )
    }

    override func tearDown() {
        sut = nil
        favoriteRepository = nil
        searchUseCase = nil
        super.tearDown()
    }

    func testSelectDrug_whenEasyDrug_setsSelectedDrugAndDoesNotEnrich() async {
        let drug = makeDrug(itemSeq: "A", itemName: "프로게스테론")

        sut.selectDrug(drug)
        await Task.yield()

        XCTAssertEqual(sut.selectedDrug?.itemSeq, "A")
        XCTAssertEqual(sut.selectedDrug?.itemName, "프로게스테론")
        XCTAssertTrue(sut.isDetailPresented)
        XCTAssertEqual(searchUseCase.executeCallCount, 0)
        XCTAssertEqual(searchUseCase.enrichCallCount, 0)
    }

    func testSelectDrug_whenEasyDrug_clearsPreviousDetailLoadingImmediately() {
        let drug = makeDrug(itemSeq: "A", itemName: "프로게스테론")
        sut.isDetailLoading = true

        sut.selectDrug(drug)

        XCTAssertFalse(sut.isDetailLoading)
        XCTAssertEqual(searchUseCase.enrichCallCount, 0)
    }

    func testSelectDrug_whenApprovalDrugNeedsDetail_enrichesSelectedDrug() async {
        let approvalInfo = makeApprovalInfo(itemSeq: "B")
        let drug = makeDrug(
            itemSeq: "B",
            itemName: "전문의약품",
            efcyQesitm: nil,
            useMethodQesitm: nil,
            approvalInfo: approvalInfo
        )
        searchUseCase.stubbedEnrichedDrug = makeDrug(
            itemSeq: "B",
            itemName: "전문의약품",
            efcyQesitm: "상세 효능",
            useMethodQesitm: "상세 용법",
            approvalInfo: approvalInfo
        )

        sut.selectDrug(drug)
        await Task.yield()
        await Task.yield()

        XCTAssertEqual(searchUseCase.enrichCallCount, 1)
        XCTAssertEqual(sut.selectedDrug?.efcyQesitm, "상세 효능")
        XCTAssertEqual(sut.selectedDrug?.useMethodQesitm, "상세 용법")
        XCTAssertFalse(sut.isDetailLoading)
    }

    func testSelectDrug_whenApprovalDrugAlreadyHasDetail_doesNotEnrich() async {
        let drug = makeDrug(
            itemSeq: "C",
            itemName: "전문의약품",
            approvalInfo: makeApprovalInfo(itemSeq: "C")
        )

        sut.selectDrug(drug)
        await Task.yield()

        XCTAssertEqual(searchUseCase.enrichCallCount, 0)
        XCTAssertEqual(sut.selectedDrug?.itemSeq, "C")
    }

    func testSelectDrug_whenGeneralApprovalDrugNeedsDetail_enrichesSelectedDrug() async {
        let drug = makeDrug(
            itemSeq: "G",
            itemName: "일반의약품",
            efcyQesitm: nil,
            useMethodQesitm: nil,
            approvalInfo: makeApprovalInfo(itemSeq: "G", specialtyPublic: "일반의약품")
        )
        searchUseCase.stubbedEnrichedDrug = makeDrug(
            itemSeq: "G",
            itemName: "일반의약품",
            efcyQesitm: "상세 효능",
            useMethodQesitm: "상세 용법",
            approvalInfo: makeApprovalInfo(itemSeq: "G", specialtyPublic: "일반의약품")
        )

        sut.selectDrug(drug)
        await Task.yield()
        await Task.yield()

        XCTAssertEqual(searchUseCase.enrichCallCount, 1)
        XCTAssertFalse(sut.isDetailLoading)
        XCTAssertEqual(sut.selectedDrug?.efcyQesitm, "상세 효능")
    }

    func testSelectDrug_whenEnrichFails_keepsOriginalDrug() async {
        let drug = makeDrug(
            itemSeq: "D",
            itemName: "전문의약품",
            efcyQesitm: nil,
            useMethodQesitm: nil,
            approvalInfo: makeApprovalInfo(itemSeq: "D")
        )
        searchUseCase.shouldThrow = AppError.networkError(URLError(.timedOut))

        sut.selectDrug(drug)
        await Task.yield()
        await Task.yield()

        XCTAssertEqual(searchUseCase.enrichCallCount, 1)
        XCTAssertEqual(sut.selectedDrug?.itemSeq, "D")
        XCTAssertNil(sut.selectedDrug?.efcyQesitm)
        XCTAssertFalse(sut.isDetailLoading)
    }
}

private extension DrugInfoViewModelTests {
    func makeDrug(
        itemSeq: String,
        itemName: String,
        efcyQesitm: String? = "효능",
        useMethodQesitm: String? = "용법",
        approvalInfo: DrugApprovalInfo? = nil
    ) -> Drug {
        Drug(
            itemSeq: itemSeq,
            itemName: itemName,
            entpName: "테스트제약",
            component: "테스트성분",
            efcyQesitm: efcyQesitm,
            useMethodQesitm: useMethodQesitm,
            atpnWarnQesitm: nil,
            atpnQesitm: nil,
            intrcQesitm: nil,
            seQesitm: nil,
            depositMethodQesitm: nil,
            itemImage: nil,
            approvalInfo: approvalInfo
        )
    }

    func makeApprovalInfo(
        itemSeq: String,
        specialtyPublic: String = "전문의약품"
    ) -> DrugApprovalInfo {
        DrugApprovalInfo(
            itemSeq: itemSeq,
            itemName: "전문의약품",
            entpName: "테스트제약",
            itemPermitDate: nil,
            barCode: nil,
            ediCode: nil,
            atcCode: nil,
            mainItemIngredient: "테스트성분",
            productType: nil,
            specialtyPublic: specialtyPublic,
            bigProductImageURL: nil,
            rareDrugYN: nil
        )
    }
}
