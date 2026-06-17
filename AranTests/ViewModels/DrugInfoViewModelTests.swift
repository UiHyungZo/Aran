@testable import Aran
import XCTest
import AranDomain

@MainActor
final class DrugInfoViewModelTests: XCTestCase {
    private var searchUseCase: MockSearchDrugUseCase!
    private var favoriteRepository: MockFavoriteDrugRepository!
    private var recentSearchRepository: MockRecentDrugSearchRepository!
    private var sut: DrugInfoViewModel!

    override func setUp() async throws {
        try await super.setUp()
        searchUseCase = MockSearchDrugUseCase()
        favoriteRepository = MockFavoriteDrugRepository()
        recentSearchRepository = MockRecentDrugSearchRepository()
        sut = DrugInfoViewModel(
            searchDrugUseCase: searchUseCase,
            favoriteDrugUseCase: FavoriteDrugUseCase(repository: favoriteRepository),
            recentSearchUseCase: RecentDrugSearchUseCase(repository: recentSearchRepository)
        )
        // init에서 시작된 Task (loadRecentSearches, loadFavorites) 소진
        await Task.yield()
        await Task.yield()
        await Task.yield()
    }

    override func tearDown() async throws {
        sut = nil
        recentSearchRepository = nil
        favoriteRepository = nil
        searchUseCase = nil
        // 이전 테스트의 Task 잔여 실행이 다음 테스트 yield 예산을 소비하지 않도록 draining
        for _ in 0..<10 { await Task.yield() }
        try await super.tearDown()
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
        await waitUntil(!self.sut.isDetailLoading)

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
        await waitUntil(!self.sut.isDetailLoading)

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
        await waitUntil(!self.sut.isDetailLoading)

        XCTAssertEqual(searchUseCase.enrichCallCount, 1)
        XCTAssertEqual(sut.selectedDrug?.itemSeq, "D")
        XCTAssertNil(sut.selectedDrug?.efcyQesitm)
        XCTAssertFalse(sut.isDetailLoading)
    }

    func testSearch_whenSearchSucceeds_savesRecentSearchKeyword() async {
        searchUseCase.stubbedResult = DrugSearchResult(
            drugs: [makeDrug(itemSeq: "A", itemName: "프로게스테론")],
            totalCount: 1,
            pageNo: 1
        )

        await sut.search(keyword: " 프로게스테론 ")

        XCTAssertEqual(recentSearchRepository.savedKeywords, ["프로게스테론"])
        XCTAssertEqual(sut.recentSearches, ["프로게스테론"])
    }

    // MARK: - enrich 캐싱

    func testEnrich_whenDrugIsFavorited_updatesDetailInFavorites() async {
        // given: 효능이 없는 약을 즐겨찾기에 미리 저장
        let drug = makeDrug(
            itemSeq: "A", itemName: "전문의약품",
            efcyQesitm: nil, useMethodQesitm: nil,
            approvalInfo: makeApprovalInfo(itemSeq: "A")
        )
        favoriteRepository.favoriteDrugs = [FavoriteDrug(drug: drug)]
        searchUseCase.stubbedEnrichedDrug = makeDrug(
            itemSeq: "A", itemName: "전문의약품",
            efcyQesitm: "상세 효능", useMethodQesitm: "상세 용법",
            approvalInfo: makeApprovalInfo(itemSeq: "A")
        )

        // when: 상세 진입 → enrich 완료 대기
        sut.selectDrug(drug)
        await waitUntil(!self.sut.isDetailLoading)

        // then: 즐겨찾기에 enrich된 데이터가 저장됨
        XCTAssertEqual(favoriteRepository.savedDrugs.last?.efcyQesitm, "상세 효능")
        XCTAssertEqual(favoriteRepository.savedDrugs.last?.useMethodQesitm, "상세 용법")
    }

    func testEnrich_whenDrugIsNotFavorited_doesNotUpdateFavorites() async {
        // given: 즐겨찾기 없음
        let drug = makeDrug(
            itemSeq: "A", itemName: "전문의약품",
            efcyQesitm: nil, useMethodQesitm: nil,
            approvalInfo: makeApprovalInfo(itemSeq: "A")
        )
        favoriteRepository.favoriteDrugs = []
        searchUseCase.stubbedEnrichedDrug = makeDrug(
            itemSeq: "A", itemName: "전문의약품",
            efcyQesitm: "상세 효능", useMethodQesitm: "상세 용법",
            approvalInfo: makeApprovalInfo(itemSeq: "A")
        )

        // when
        sut.selectDrug(drug)
        await waitUntil(!self.sut.isDetailLoading)

        // then: 즐겨찾기 저장 호출 없음
        XCTAssertTrue(favoriteRepository.savedDrugs.isEmpty)
    }

    // MARK: - clearDetailState

    func testClearDetailState_whenPendingFavoriteToggle_performsToggleImmediately() async {
        // given: 상세 로딩 중 즐겨찾기 탭
        let drug = makeDrug(
            itemSeq: "A", itemName: "전문의약품",
            efcyQesitm: nil, useMethodQesitm: nil,
            approvalInfo: makeApprovalInfo(itemSeq: "A")
        )
        sut.selectDrug(drug)        // isDetailLoading = true
        sut.toggleFavorite(drug)    // pendingFavoriteToggle = true (loading 중이므로 defer)

        // when: 뒤로가기 → clearDetailState 호출
        sut.clearDetailState()
        await waitUntil(!self.favoriteRepository.savedDrugs.isEmpty)

        // then: pending toggle이 즉시 실행되어 즐겨찾기에 저장됨
        XCTAssertEqual(favoriteRepository.savedDrugs.map(\.itemSeq), ["A"])
    }

    func testClearDetailState_whenNoPendingFavoriteToggle_doesNotToggle() async {
        // given: 상세 로딩 중 즐겨찾기 미탭
        let drug = makeDrug(
            itemSeq: "A", itemName: "전문의약품",
            efcyQesitm: nil, useMethodQesitm: nil,
            approvalInfo: makeApprovalInfo(itemSeq: "A")
        )
        sut.selectDrug(drug)    // isDetailLoading = true, 즐겨찾기 탭 없음

        // when
        sut.clearDetailState()
        await Task.yield()
        await Task.yield()

        // then: 즐겨찾기 변경 없음
        XCTAssertTrue(favoriteRepository.savedDrugs.isEmpty)
    }

    func testClearDetailState_resetsLoadingState() {
        // given
        let drug = makeDrug(
            itemSeq: "A", itemName: "전문의약품",
            efcyQesitm: nil, useMethodQesitm: nil,
            approvalInfo: makeApprovalInfo(itemSeq: "A")
        )
        sut.selectDrug(drug)
        XCTAssertTrue(sut.isDetailLoading)

        // when
        sut.clearDetailState()

        // then
        XCTAssertFalse(sut.isDetailLoading)
    }

    // MARK: - Async helpers

    /// 조건이 참이 될 때까지 MainActor를 최대 50회 양보한다.
    func waitUntil(_ condition: @autoclosure @escaping () -> Bool) async {
        for _ in 0..<50 {
            await Task.yield()
            if condition() { return }
        }
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
