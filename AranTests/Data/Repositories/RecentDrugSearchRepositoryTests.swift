@testable import Aran
import SwiftData
import XCTest
import AranDomain

final class RecentDrugSearchRepositoryTests: XCTestCase {
    private var container: ModelContainer!
    private var sut: RecentDrugSearchRepository!

    override func setUp() async throws {
        try await super.setUp()
        let schema = Schema([RecentDrugSearchModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: config)
        sut = RecentDrugSearchRepository(context: ModelContext(container))
    }

    override func tearDown() async throws {
        sut = nil
        container = nil
        try await super.tearDown()
    }

    func testSave_whenKeywordIsValid_thenFetchAllContainsIt() async throws {
        try await sut.save(keyword: "프로게스테론")

        let result = try await sut.fetchAll()

        XCTAssertEqual(result.map(\.keyword), ["프로게스테론"])
    }

    func testSave_whenKeywordAlreadyExists_thenMovesToTopWithoutDuplicating() async throws {
        try await sut.save(keyword: "A")
        try await Task.sleep(nanoseconds: 1_000_000)
        try await sut.save(keyword: "B")
        try await Task.sleep(nanoseconds: 1_000_000)
        try await sut.save(keyword: "A")

        let result = try await sut.fetchAll()

        XCTAssertEqual(result.map(\.keyword), ["A", "B"])
    }

    func testSave_whenMoreThanTenKeywords_keepsLatestTen() async throws {
        for index in 0..<11 {
            try await sut.save(keyword: "keyword-\(index)")
            try await Task.sleep(nanoseconds: 1_000_000)
        }

        let result = try await sut.fetchAll()

        XCTAssertEqual(result.count, 10)
        XCTAssertEqual(result.first?.keyword, "keyword-10")
        XCTAssertFalse(result.map(\.keyword).contains("keyword-0"))
    }

    func testDelete_whenKeywordExists_thenRemovesIt() async throws {
        try await sut.save(keyword: "A")

        try await sut.delete(keyword: "A")
        let result = try await sut.fetchAll()

        XCTAssertTrue(result.isEmpty)
    }

    func testClear_removesAllKeywords() async throws {
        try await sut.save(keyword: "A")
        try await sut.save(keyword: "B")

        try await sut.clear()
        let result = try await sut.fetchAll()

        XCTAssertTrue(result.isEmpty)
    }
}
