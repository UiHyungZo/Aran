@testable import Aran
import SwiftData
import XCTest

@MainActor
final class DiaryEntryRepositoryTests: XCTestCase {
    private var container: ModelContainer!
    private var sut: DiaryEntryRepository!

    override func setUp() async throws {
        try await super.setUp()
        let schema = Schema([DiaryEntryModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: config)
        sut = DiaryEntryRepository(context: ModelContext(container))
    }

    override func tearDown() async throws {
        sut = nil
        container = nil
        try await super.tearDown()
    }

    func test_save_whenEntryIsValid_thenFetchAllContainsIt() async throws {
        // given
        let entry = makeEntry(content: "좋은 하루")

        // when
        try await sut.save(entry)
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, entry.id)
        XCTAssertEqual(result.first?.content, "좋은 하루")
    }

    func test_fetchByDate_whenEntryExistsForThatDay_thenReturnsIt() async throws {
        // given
        let date = makeDate(day: 1, hour: 9)
        let entry = makeEntry(date: date)
        try await sut.save(entry)

        // when
        let result = try await sut.fetch(date: makeDate(day: 1, hour: 20))

        // then
        XCTAssertEqual(result?.id, entry.id)
    }

    func test_update_whenEntryExists_thenUpdatesStoredValues() async throws {
        // given
        var entry = makeEntry(emoji: "🙂", content: "초기 내용")
        try await sut.save(entry)
        entry.emoji = "🥲"
        entry.content = "수정된 내용"

        // when
        try await sut.update(entry)
        let result = try await sut.fetch(date: entry.date)

        // then
        XCTAssertEqual(result?.emoji, "🥲")
        XCTAssertEqual(result?.content, "수정된 내용")
    }

    func test_delete_whenEntryExists_thenRemovedFromList() async throws {
        // given
        let entry = makeEntry()
        try await sut.save(entry)

        // when
        try await sut.delete(id: entry.id)
        let result = try await sut.fetchAll()

        // then
        XCTAssertFalse(result.contains { $0.id == entry.id })
    }

    func test_fetchAll_whenMultipleEntries_thenSortedByDateDescending() async throws {
        // given
        let earlier = makeEntry(date: makeDate(day: 1), content: "이전")
        let later = makeEntry(date: makeDate(day: 2), content: "최근")
        try await sut.save(earlier)
        try await sut.save(later)

        // when
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.map(\.content), ["최근", "이전"])
    }
}

private extension DiaryEntryRepositoryTests {
    func makeEntry(
        date: Date = Date(),
        emoji: String? = "🙂",
        content: String = "기록"
    ) -> DiaryEntry {
        DiaryEntry(id: UUID(), date: date, emoji: emoji, content: content)
    }

    func makeDate(day: Int, hour: Int = 9) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: day, hour: hour)) ?? Date()
    }
}
