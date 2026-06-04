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

    func testSave_whenUpdatingExistingFavorite_preservesCreatedAt() async throws {
        // given: 특정 시점에 저장된 즐겨찾기
        let originalDate = Date(timeIntervalSince1970: 1_000_000)
        try await sut.save(makeFavorite(itemSeq: "A", efcyQesitm: nil, createdAt: originalDate))

        // when: enrich 후 갱신 저장 (새 createdAt 포함)
        try await sut.save(makeFavorite(itemSeq: "A", efcyQesitm: "상세 효능", createdAt: Date()))

        // then: 정렬 기준인 createdAt은 원래 값 유지, 상세 내용은 갱신됨
        let result = try await sut.fetchAll()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.createdAt, originalDate)
        XCTAssertEqual(result.first?.efcyQesitm, "상세 효능")
    }
}

private extension FavoriteDrugRepositoryTests {
    func makeFavorite(
        itemSeq: String,
        itemName: String = "프로게스테론",
        efcyQesitm: String? = "효능",
        createdAt: Date = Date()
    ) -> FavoriteDrug {
        FavoriteDrug(
            id: UUID(),
            itemSeq: itemSeq,
            itemName: itemName,
            entpName: "제약사",
            component: "Progesterone",
            efcyQesitm: efcyQesitm,
            useMethodQesitm: nil,
            atpnWarnQesitm: nil,
            atpnQesitm: nil,
            intrcQesitm: nil,
            seQesitm: nil,
            depositMethodQesitm: nil,
            itemImage: nil,
            createdAt: createdAt
        )
    }
}
