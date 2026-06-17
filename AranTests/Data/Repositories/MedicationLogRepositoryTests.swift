@testable import Aran
import SwiftData
import XCTest
import AranDomain
import AranData

@MainActor
final class MedicationLogRepositoryTests: XCTestCase {
    private var container: ModelContainer!
    private var sut: MedicationLogRepository!

    override func setUp() async throws {
        try await super.setUp()
        let schema = Schema([MedicationLogModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: config)
        sut = MedicationLogRepository(context: ModelContext(container))
    }

    override func tearDown() async throws {
        sut = nil
        container = nil
        try await super.tearDown()
    }

    func test_upsert_whenLogDoesNotExist_thenFetchAllContainsIt() async throws {
        // given
        let log = makeLog(isTaken: true)

        // when
        try await sut.upsert(log)
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, log.id)
        XCTAssertTrue(result.first?.isTaken ?? false)
    }

    func test_fetchByDate_whenLogsExist_thenReturnsOnlyMatchingDate() async throws {
        // given
        let matching = makeLog(date: makeDate(day: 1, hour: 9))
        let other = makeLog(date: makeDate(day: 2, hour: 9))
        try await sut.upsert(matching)
        try await sut.upsert(other)

        // when
        let result = try await sut.fetch(date: makeDate(day: 1, hour: 20))

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, matching.id)
    }

    func test_upsert_whenSameMedicationDateAndTimeSlot_thenUpdatesWithoutDuplicate() async throws {
        // given
        let medicationId = UUID()
        let timeSlotID = UUID()
        let first = makeLog(medicationId: medicationId, timeSlotID: timeSlotID, isTaken: true)
        let updated = makeLog(medicationId: medicationId, timeSlotID: timeSlotID, isTaken: false)
        try await sut.upsert(first)

        // when
        try await sut.upsert(updated)
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, first.id)
        XCTAssertFalse(result.first?.isTaken ?? true)
    }

    func test_fetchByMedicationDateAndTimeSlot_whenMatchingLogExists_thenReturnsIt() async throws {
        // given
        let medicationId = UUID()
        let targetSlotID = UUID()
        let otherSlotID = UUID()
        let target = makeLog(medicationId: medicationId, timeSlotID: targetSlotID)
        let other = makeLog(medicationId: medicationId, timeSlotID: otherSlotID)
        try await sut.upsert(target)
        try await sut.upsert(other)

        // when
        let result = try await sut.fetch(
            medicationId: medicationId,
            date: target.logDate,
            timeSlotID: targetSlotID
        )

        // then
        XCTAssertEqual(result?.id, target.id)
        XCTAssertEqual(result?.timeSlotID, targetSlotID)
    }

    func test_deleteLogs_whenMedicationHasLogs_thenRemovesOnlyMatchingMedication() async throws {
        // given
        let medicationId = UUID()
        let matching = makeLog(medicationId: medicationId)
        let other = makeLog(medicationId: UUID())
        try await sut.upsert(matching)
        try await sut.upsert(other)

        // when
        try await sut.deleteLogs(for: medicationId)
        let result = try await sut.fetchAll()

        // then
        XCTAssertFalse(result.contains { $0.medicationId == medicationId })
        XCTAssertTrue(result.contains { $0.id == other.id })
    }
}

private extension MedicationLogRepositoryTests {
    func makeLog(
        medicationId: UUID = UUID(),
        date: Date = Date(),
        timeSlotID: UUID = UUID(),
        isTaken: Bool = true
    ) -> MedicationLog {
        MedicationLog(
            id: UUID(),
            medicationId: medicationId,
            logDate: date,
            isTaken: isTaken,
            timeSlotID: timeSlotID
        )
    }

    func makeDate(day: Int, hour: Int = 9) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: day, hour: hour)) ?? Date()
    }
}
