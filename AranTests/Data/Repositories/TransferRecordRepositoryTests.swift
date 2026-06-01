@testable import Aran
import SwiftData
import XCTest

@MainActor
final class TransferRecordRepositoryTests: XCTestCase {
    private var container: ModelContainer!
    private var sut: TransferRecordRepository!

    override func setUp() async throws {
        try await super.setUp()
        let schema = Schema([TransferRecordModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: config)
        sut = TransferRecordRepository(context: ModelContext(container))
    }

    override func tearDown() async throws {
        sut = nil
        container = nil
        try await super.tearDown()
    }

    func test_save_whenRecordIsValid_thenFetchAllContainsIt() async throws {
        // given
        let record = makeRecord(grade: "4AA", count: 2)

        // when
        try await sut.save(record)
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.embryoGrade, "4AA")
        XCTAssertEqual(result.first?.embryoCount, 2)
    }

    func test_fetchByID_whenRecordExists_thenReturnsIt() async throws {
        // given
        let record = makeRecord()
        try await sut.save(record)

        // when
        let result = try await sut.fetch(id: record.id)

        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, record.id)
    }

    func test_fetchByID_whenRecordNotFound_thenReturnsNil() async throws {
        // when
        let result = try await sut.fetch(id: UUID())

        // then
        XCTAssertNil(result)
    }

    func test_fetchByDate_whenRecordExistsForThatDay_thenReturnsIt() async throws {
        // given
        let today = Calendar.current.startOfDay(for: Date())
        let record = makeRecord(date: today)
        try await sut.save(record)

        // when
        let result = try await sut.fetch(for: today)

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, record.id)
    }

    func test_fetchByDate_whenRecordIsOnDifferentDay_thenReturnsEmpty() async throws {
        // given
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let record = makeRecord(date: yesterday)
        try await sut.save(record)

        // when
        let result = try await sut.fetch(for: Date())

        // then
        XCTAssertTrue(result.isEmpty)
    }

    func test_update_whenRecordExists_thenUpdatesStoredValues() async throws {
        // given
        var record = makeRecord(grade: "3BB", result: .waiting)
        try await sut.save(record)
        record.embryoGrade = "5AA"
        record.result = .pregnant

        // when
        try await sut.update(record)
        let fetched = try await sut.fetch(id: record.id)

        // then
        XCTAssertEqual(fetched?.embryoGrade, "5AA")
        XCTAssertEqual(fetched?.result, .pregnant)
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
        let earlier = makeRecord(date: Date(timeIntervalSinceNow: -86400))
        let later = makeRecord(date: Date(), grade: "5AA")
        try await sut.save(earlier)
        try await sut.save(later)

        // when
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.embryoGrade, "5AA")
    }
}

private extension TransferRecordRepositoryTests {
    func makeRecord(
        date: Date = Date(),
        grade: String = "3BB",
        count: Int = 1,
        transferType: TransferType = .frozen,
        result: TransferResult = .waiting
    ) -> TransferRecord {
        TransferRecord(
            id: UUID(),
            cycleNumber: 1,
            date: date,
            embryoGrade: grade,
            embryoCount: count,
            transferType: transferType,
            result: result,
            memo: nil
        )
    }
}
