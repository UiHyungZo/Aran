import XCTest
import AranDomain

final class FavoriteDrugUseCaseTests: XCTestCase {
    private var repository: MockFavoriteDrugRepository!
    private var sut: FavoriteDrugUseCase!

    override func setUp() {
        super.setUp()
        repository = MockFavoriteDrugRepository()
        sut = FavoriteDrugUseCase(repository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func testFetchAll_returnsStoredFavorites() async throws {
        let favorite = FavoriteDrug(drug: makeDrug(itemSeq: "A"))
        repository.favoriteDrugs = [favorite]

        let result = try await sut.fetchAll()

        XCTAssertEqual(result.map(\.itemSeq), ["A"])
    }

    func testToggle_whenDrugIsNotFavorite_savesDrug() async throws {
        let drug = makeDrug(itemSeq: "A")

        try await sut.toggle(drug: drug)
        let isFavorite = try await sut.isFavorite(itemSeq: "A")

        XCTAssertEqual(repository.savedDrugs.map(\.itemSeq), ["A"])
        XCTAssertTrue(isFavorite)
    }

    func testToggle_whenDrugIsFavorite_deletesDrug() async throws {
        let drug = makeDrug(itemSeq: "A")
        repository.favoriteDrugs = [FavoriteDrug(drug: drug)]

        try await sut.toggle(drug: drug)
        let isFavorite = try await sut.isFavorite(itemSeq: "A")

        XCTAssertEqual(repository.deletedItemSeqs, ["A"])
        XCTAssertFalse(isFavorite)
    }

    func testUpdateDetailIfFavorited_whenFavorited_savesEnrichedData() async throws {
        // given: 효능이 없는 상태로 즐겨찾기 저장
        let sparse = makeDrug(itemSeq: "A", efcyQesitm: nil, useMethodQesitm: nil)
        repository.favoriteDrugs = [FavoriteDrug(drug: sparse)]
        repository.savedDrugs = []

        // when: enrich된 완전한 데이터로 갱신
        let enriched = makeDrug(itemSeq: "A", efcyQesitm: "상세 효능", useMethodQesitm: "상세 용법")
        try await sut.updateDetailIfFavorited(drug: enriched)

        // then: 갱신된 데이터가 저장됨
        XCTAssertEqual(repository.savedDrugs.map(\.itemSeq), ["A"])
        XCTAssertEqual(repository.savedDrugs.first?.efcyQesitm, "상세 효능")
        XCTAssertEqual(repository.savedDrugs.first?.useMethodQesitm, "상세 용법")
    }

    func testUpdateDetailIfFavorited_whenNotFavorited_doesNotSave() async throws {
        // given: 즐겨찾기 없음
        repository.favoriteDrugs = []
        repository.savedDrugs = []

        // when
        try await sut.updateDetailIfFavorited(drug: makeDrug(itemSeq: "A"))

        // then: 저장되지 않음
        XCTAssertTrue(repository.savedDrugs.isEmpty)
    }
}

private extension FavoriteDrugUseCaseTests {
    func makeDrug(
        itemSeq: String,
        efcyQesitm: String? = "효능",
        useMethodQesitm: String? = "사용법"
    ) -> Drug {
        Drug(
            itemSeq: itemSeq,
            itemName: "프로게스테론",
            entpName: "제약사",
            component: "Progesterone",
            efcyQesitm: efcyQesitm,
            useMethodQesitm: useMethodQesitm,
            atpnWarnQesitm: nil,
            atpnQesitm: nil,
            intrcQesitm: nil,
            seQesitm: nil,
            depositMethodQesitm: nil,
            itemImage: nil
        )
    }
}
