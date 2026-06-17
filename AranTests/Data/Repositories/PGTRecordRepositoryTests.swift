@testable import Aran
import SwiftData
import XCTest
import AranDomain

@MainActor
final class PGTRecordRepositoryTests: XCTestCase {
    private var container: ModelContainer!
    private var sut: PGTRecordRepository!

    override func setUp() async throws {
        try await super.setUp()
        let schema = Schema([PGTRecordModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: config)
        sut = PGTRecordRepository(context: ModelContext(container))
    }

    override func tearDown() async throws {
        sut = nil
        container = nil
        try await super.tearDown()
    }

    func test_save_whenRecordIsValid_thenFetchAllContainsIt() async throws {
        // given
        let record = makeRecord(type: .pgtA, normalCount: 2)

        // when
        try await sut.save(record)
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, record.id)
        XCTAssertEqual(result.first?.normalCount, 2)
    }

    func test_fetchByCycleRecordId_whenRecordsExist_thenReturnsOnlyMatchingCycle() async throws {
        // given
        let cycleRecordId = UUID()
        let matching = makeRecord(cycleRecordId: cycleRecordId, testDate: makeDate(day: 1))
        let other = makeRecord(cycleRecordId: UUID(), testDate: makeDate(day: 1))
        try await sut.save(matching)
        try await sut.save(other)

        // when
        let result = try await sut.fetch(cycleRecordId: cycleRecordId)

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, matching.id)
    }

    func test_update_whenRecordExists_thenUpdatesCountsAndDetailFields() async throws {
        // given
        var record = makeRecord(type: .pgtA, normalCount: 1, memo: "초기")
        try await sut.save(record)
        record.type = .implantation
        record.normalCount = 0
        record.implantationTestType = .era
        record.implantationResult = .receptive
        record.recommendedTransferWindow = "132시간"
        record.memo = "수정"

        // when
        try await sut.update(record)
        let result = try await sut.fetch(id: record.id)

        // then
        XCTAssertEqual(result?.type, .implantation)
        XCTAssertEqual(result?.implantationTestType, .era)
        XCTAssertEqual(result?.implantationResult, .receptive)
        XCTAssertEqual(result?.recommendedTransferWindow, "132시간")
        XCTAssertEqual(result?.memo, "수정")
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
        let earlier = makeRecord(testDate: makeDate(day: 1), memo: "이전")
        let later = makeRecord(testDate: makeDate(day: 2), memo: "최근")
        try await sut.save(earlier)
        try await sut.save(later)

        // when
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.map(\.memo), ["최근", "이전"])
    }
}

private extension PGTRecordRepositoryTests {
    func makeRecord(
        cycleRecordId: UUID = UUID(),
        testDate: Date = Date(),
        type: PGTType = .pgtA,
        normalCount: Int = 1,
        abnormalCount: Int = 0,
        mosaicCount: Int = 0,
        memo: String? = nil
    ) -> PGTRecord {
        PGTRecord(
            id: UUID(),
            cycleRecordId: cycleRecordId,
            testDate: testDate,
            type: type,
            normalCount: normalCount,
            abnormalCount: abnormalCount,
            mosaicCount: mosaicCount,
            inconclusiveCount: 0,
            resultStatus: .normal,
            femaleChromosomeResult: nil,
            maleChromosomeResult: nil,
            implantationTestType: nil,
            implantationResult: nil,
            recommendedTransferWindow: nil,
            memo: memo
        )
    }

    func makeDate(day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: day, hour: 9)) ?? Date()
    }
}
