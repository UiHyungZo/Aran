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
        let record = makeHealthRecord(type: HealthRecordType.fsh, value: 10.5)

        // when
        try await sut.save(record)
        let result = try await sut.fetchAll()

        // then
        XCTAssertTrue(result.contains { $0.id == record.id })
        XCTAssertEqual(result.first { $0.id == record.id }?.value, 10.5)
        XCTAssertEqual(result.first { $0.id == record.id }?.unit, "mIU/mL")
    }

    func test_fetch_whenFilteredByType_thenReturnsOnlyMatchingRecords() async throws {
        // given
        let fshRecord = makeHealthRecord(type: HealthRecordType.fsh, value: 10.0)
        let amhRecord = makeHealthRecord(type: HealthRecordType.amh, value: 2.5, unit: "ng/mL")
        try await sut.save(fshRecord)
        try await sut.save(amhRecord)

        // when
        let result = try await sut.fetch(type: HealthRecordType.fsh)

        // then
        XCTAssertTrue(result.allSatisfy { $0.type == HealthRecordType.fsh })
        XCTAssertFalse(result.contains { $0.type == HealthRecordType.amh })
    }

    func test_update_whenRecordExists_thenUpdatesStoredModel() async throws {
        // given
        var record = makeHealthRecord(type: HealthRecordType.e2, value: 300.0, unit: "pg/mL")
        try await sut.save(record)
        record.value = 350.0
        record.memo = "재검"

        // when
        try await sut.update(record)
        let result = try await sut.fetch(type: HealthRecordType.e2)

        // then
        XCTAssertEqual(result.first?.value, 350.0)
        XCTAssertEqual(result.first?.memo, "재검")
    }

    func test_delete_whenRecordExists_thenRemovedFromList() async throws {
        // given
        let record = makeHealthRecord(type: HealthRecordType.e2, value: 300.0, unit: "pg/mL")
        try await sut.save(record)

        // when
        try await sut.delete(id: record.id)
        let result = try await sut.fetchAll()

        // then
        XCTAssertFalse(result.contains { $0.id == record.id })
    }

    func test_fetchAll_thenSortedByDateDescending() async throws {
        // given
        let earlier = makeHealthRecord(value: 5.0, date: Date(timeIntervalSinceNow: -86400))
        let later = makeHealthRecord(value: 8.0, date: Date())
        try await sut.save(earlier)
        try await sut.save(later)

        // when
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.value, 8.0)
    }
}

private extension HealthRecordRepositoryTests {
    func makeHealthRecord(
        type: String = HealthRecordType.fsh,
        value: Double,
        unit: String = "mIU/mL",
        date: Date = Date()
    ) -> HealthRecord {
        HealthRecord(
            id: UUID(),
            type: type,
            value: value,
            unit: unit,
            recordDate: date,
            memo: nil
        )
    }
}
