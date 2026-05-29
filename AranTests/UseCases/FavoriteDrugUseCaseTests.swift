@testable import Aran
import XCTest

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
}

private extension FavoriteDrugUseCaseTests {
    func makeDrug(itemSeq: String) -> Drug {
        Drug(
            itemSeq: itemSeq,
            itemName: "프로게스테론",
            entpName: "제약사",
            component: "Progesterone",
            efcyQesitm: "효능",
            useMethodQesitm: "사용법",
            atpnWarnQesitm: nil,
            atpnQesitm: nil,
            intrcQesitm: nil,
            seQesitm: nil,
            depositMethodQesitm: nil,
            itemImage: nil
        )
    }
}
