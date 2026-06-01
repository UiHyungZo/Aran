@testable import Aran
import SwiftData
import XCTest

@MainActor
final class CycleRecordRepositoryTests: XCTestCase {
    private var container: ModelContainer!
    private var sut: CycleRecordRepository!

    override func setUp() async throws {
        try await super.setUp()
        let schema = Schema([CycleRecordModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: config)
        sut = CycleRecordRepository(context: ModelContext(container))
    }

    override func tearDown() async throws {
        sut = nil
        container = nil
        try await super.tearDown()
    }

    func test_save_whenRecordIsValid_thenFetchAllContainsIt() async throws {
        // given
        let record = makeRecord(cycleNumber: 1, retrieval: 5)

        // when
        try await sut.save(record)
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, record.id)
        XCTAssertEqual(result.first?.retrievalCount, 5)
    }

    func test_fetchByDate_whenRecordExistsForThatDay_thenReturnsIt() async throws {
        // given
        let today = Calendar.current.startOfDay(for: Date())
        let record = makeRecord(date: today)
        try await sut.save(record)

        // when
        let result = try await sut.fetch(date: today)

        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, record.id)
    }

    func test_fetchByDate_whenNoRecordForDate_thenReturnsNil() async throws {
        // given
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

        // when
        let result = try await sut.fetch(date: yesterday)

        // then
        XCTAssertNil(result)
    }

    func test_update_whenRecordExists_thenUpdatesStoredValues() async throws {
        // given
        var record = makeRecord(cycleNumber: 1, retrieval: 3)
        try await sut.save(record)
        record.retrievalCount = 7
        record.fertilizedCount = 5

        // when
        try await sut.update(record)
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.first?.retrievalCount, 7)
        XCTAssertEqual(result.first?.fertilizedCount, 5)
    }

    func test_delete_whenRecordExists_thenRemovedFromList() async throws {
        // given
        let record = makeRecord()
        try await sut.save(record)

        // when
        try await sut.delete(id: record.id)
        let result = try await sut.fetchAll()

        // then
        XCTAssertFalse(result.contains { $0.id == record.id })
    }

    func test_fetchAll_whenMultipleRecords_thenSortedByDateDescending() async throws {
        // given
        let earlier = makeRecord(date: Date(timeIntervalSinceNow: -86400), cycleNumber: 1)
        let later = makeRecord(date: Date(), cycleNumber: 2)
        try await sut.save(earlier)
        try await sut.save(later)

        // when
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.cycleNumber, 2)
    }

    func test_save_withEmbryoRetrievalEvent_thenPreservesEventAfterFetch() async throws {
        // given
        let record = makeRecord(events: [.embryoRetrieval(count: 4)])

        // when
        try await sut.save(record)
        let result = try await sut.fetchAll()

        // then
        let events = result.first?.events ?? []
        XCTAssertTrue(events.contains {
            guard case let .embryoRetrieval(count) = $0 else { return false }
            return count == 4
        })
    }
}

private extension CycleRecordRepositoryTests {
    func makeRecord(
        date: Date = Date(),
        cycleNumber: Int = 1,
        retrieval: Int = 0,
        events: [DayEvent] = []
    ) -> CycleRecord {
        CycleRecord(
            id: UUID(),
            cycleNumber: cycleNumber,
            date: date,
            retrievalCount: retrieval,
            events: events,
            diary: nil
        )
    }
}
