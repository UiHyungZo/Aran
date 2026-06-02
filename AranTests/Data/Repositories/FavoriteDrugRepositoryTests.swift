@testable import Aran
import SwiftData
import XCTest

final class FavoriteDrugRepositoryTests: XCTestCase {
    private var container: ModelContainer!
    private var sut: FavoriteDrugRepository!

    override func setUp() async throws {
        try await super.setUp()
        let schema = Schema([FavoriteDrugModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: config)
        sut = FavoriteDrugRepository(context: ModelContext(container))
    }

    override func tearDown() async throws {
        sut = nil
        container = nil
        try await super.tearDown()
    }

    func testSave_whenFavoriteDrugIsValid_thenFetchAllContainsIt() async throws {
        let favorite = makeFavorite(itemSeq: "A")

        try await sut.save(favorite)
        let result = try await sut.fetchAll()

        XCTAssertEqual(result.map(\.itemSeq), ["A"])
        XCTAssertEqual(result.first?.itemName, "프로게스테론")
    }

    func testSave_whenItemSeqAlreadyExists_thenUpdatesExistingFavorite() async throws {
        try await sut.save(makeFavorite(itemSeq: "A", itemName: "원래약"))

        try await sut.save(makeFavorite(itemSeq: "A", itemName: "수정된약"))
        let result = try await sut.fetchAll()

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.itemName, "수정된약")
    }

    func testDelete_whenFavoriteExists_thenRemovedFromList() async throws {
        try await sut.save(makeFavorite(itemSeq: "A"))

        try await sut.delete(itemSeq: "A")
        let result = try await sut.fetchAll()
        let exists = try await sut.exists(itemSeq: "A")

        XCTAssertTrue(result.isEmpty)
        XCTAssertFalse(exists)
    }
}

private extension FavoriteDrugRepositoryTests {
    func makeFavorite(itemSeq: String, itemName: String = "프로게스테론") -> FavoriteDrug {
        FavoriteDrug(
            id: UUID(),
            itemSeq: itemSeq,
            itemName: itemName,
            entpName: "제약사",
            component: "Progesterone",
            efcyQesitm: "효능",
            useMethodQesitm: nil,
            atpnWarnQesitm: nil,
            atpnQesitm: nil,
            intrcQesitm: nil,
            seQesitm: nil,
            depositMethodQesitm: nil,
            itemImage: nil
        )
    }
}
