@testable import Aran
import XCTest

final class RecentDrugSearchUseCaseTests: XCTestCase {
    private var repository: MockRecentDrugSearchRepository!
    private var sut: RecentDrugSearchUseCase!

    override func setUp() {
        super.setUp()
        repository = MockRecentDrugSearchRepository()
        sut = RecentDrugSearchUseCase(repository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func testFetchAll_returnsKeywordsInRepositoryOrder() async throws {
        repository.searches = [
            RecentDrugSearch(keyword: "A", createdAt: Date(timeIntervalSince1970: 1)),
            RecentDrugSearch(keyword: "B", createdAt: Date(timeIntervalSince1970: 2)),
        ]

        let result = try await sut.fetchAll()

        XCTAssertEqual(result, ["B", "A"])
    }

    func testSave_whenKeywordHasWhitespace_savesTrimmedKeyword() async throws {
        try await sut.save(keyword: "  프로게스테론  ")

        XCTAssertEqual(repository.savedKeywords, ["프로게스테론"])
    }

    func testSave_whenKeywordIsEmpty_doesNotSave() async throws {
        try await sut.save(keyword: "   ")

        XCTAssertTrue(repository.savedKeywords.isEmpty)
    }

    func testDelete_deletesKeyword() async throws {
        try await sut.delete(keyword: "프로게스테론")

        XCTAssertEqual(repository.deletedKeywords, ["프로게스테론"])
    }

    func testClear_clearsRepository() async throws {
        try await sut.clear()

        XCTAssertEqual(repository.clearCallCount, 1)
    }
}
