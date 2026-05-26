@testable import Aran
import SwiftData
import XCTest

@MainActor
final class HealthRecordRepositoryTests: XCTestCase {
    private var container: ModelContainer!
    private var sut: HealthRecordRepository!

    override func setUp() async throws {
        try await super.setUp()
        let schema = Schema([HealthRecordModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: config)
        sut = HealthRecordRepository(context: ModelContext(container))
    }

    override func tearDown() async throws {
        sut = nil
        container = nil
        try await super.tearDown()
    }

    func test_save_whenRecordIsValid_thenFetchAllContainsIt() async throws {
        // given
        let record = makeHealthRecord(item: .fsh, value: 10.5)

        // when
        try await sut.save(record)
        let result = try await sut.fetchAll()

        // then
        XCTAssertTrue(result.contains { $0.id == record.id })
        XCTAssertEqual(result.first { $0.id == record.id }?.value, 10.5)
    }

    func test_fetch_whenFilteredByItem_thenReturnsOnlyMatchingRecords() async throws {
        // given
        let fshRecord = makeHealthRecord(item: .fsh, value: 10.0)
        let amhRecord = makeHealthRecord(item: .amh, value: 2.5)
        try await sut.save(fshRecord)
        try await sut.save(amhRecord)

        // when
        let result = try await sut.fetch(item: .fsh)

        // then
        XCTAssertTrue(result.allSatisfy { $0.testItem == .fsh })
        XCTAssertFalse(result.contains { $0.testItem == .amh })
    }

    func test_delete_whenRecordExists_thenRemovedFromList() async throws {
        // given
        let record = makeHealthRecord(item: .e2, value: 300.0)
        try await sut.save(record)

        // when
        try await sut.delete(id: record.id)
        let result = try await sut.fetchAll()

        // then
        XCTAssertFalse(result.contains { $0.id == record.id })
    }

    func test_fetchAll_thenSortedByDateDescending() async throws {
        // given
        let earlier = makeHealthRecord(item: .fsh, value: 5.0, date: Date(timeIntervalSinceNow: -86400))
        let later = makeHealthRecord(item: .fsh, value: 8.0, date: Date())
        try await sut.save(earlier)
        try await sut.save(later)

        // when
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.value, 8.0, "가장 최근 기록이 첫 번째여야 한다")
    }
}

// MARK: - Helpers

private extension HealthRecordRepositoryTests {
    func makeHealthRecord(
        item: TestItem,
        value: Double,
        date: Date = Date()
    ) -> HealthRecord {
        HealthRecord(
            id: UUID(),
            testItem: item,
            value: value,
            date: date,
            note: nil,
            pgtResult: nil
        )
    }
}
