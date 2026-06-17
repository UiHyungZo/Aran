import XCTest
import AranDomain

final class MedicationLogUseCaseTests: XCTestCase {
    private var repository: MockMedicationLogRepository!
    private var sut: MedicationLogUseCase!

    override func setUp() {
        super.setUp()
        repository = MockMedicationLogRepository()
        sut = MedicationLogUseCase(repository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_toggle_whenLogDoesNotExist_thenSavesTakenLog() async throws {
        // given
        let medicationId = UUID()
        let date = Date()
        let timeSlotID = UUID()

        // when
        try await sut.toggle(medicationId: medicationId, date: date, timeSlotID: timeSlotID)

        // then
        let log = try await repository.fetch(medicationId: medicationId, date: date, timeSlotID: timeSlotID)
        XCTAssertEqual(log?.isTaken, true)
        XCTAssertEqual(log?.timeSlotID, timeSlotID)
    }

    func test_toggle_whenLogExists_thenTogglesTakenState() async throws {
        // given
        let medicationId = UUID()
        let date = Date()
        let timeSlotID = UUID()
        try await repository.upsert(MedicationLog(
            id: UUID(),
            medicationId: medicationId,
            logDate: date,
            isTaken: true,
            timeSlotID: timeSlotID
        ))

        // when
        try await sut.toggle(medicationId: medicationId, date: date, timeSlotID: timeSlotID)

        // then
        let log = try await repository.fetch(medicationId: medicationId, date: date, timeSlotID: timeSlotID)
        XCTAssertEqual(log?.isTaken, false)
    }

    func test_toggle_whenSameMedicationAndDate_thenDoesNotCreateDuplicateLog() async throws {
        // given
        let medicationId = UUID()
        let date = Date()
        let timeSlotID = UUID()

        // when
        try await sut.toggle(medicationId: medicationId, date: date, timeSlotID: timeSlotID)
        try await sut.toggle(medicationId: medicationId, date: date, timeSlotID: timeSlotID)

        // then
        XCTAssertEqual(repository.logs.count, 1)
    }

    // MARK: - fetch(date:)

    func test_fetchByDate_returnsOnlyLogsForThatDate() async throws {
        // given
        let targetDate = makeDay(year: 2026, month: 5, day: 1)
        let otherDate = makeDay(year: 2026, month: 5, day: 2)
        let medicationId = UUID()

        repository.logs = [
            makeLog(medicationId: medicationId, date: targetDate),
            makeLog(medicationId: medicationId, date: otherDate),
        ]

        // when
        let result = try await sut.fetch(date: targetDate)

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertTrue(Calendar.current.isDate(result[0].logDate, inSameDayAs: targetDate))
    }

    // MARK: - fetch(medicationId:date:)

    func test_fetchByMedicationIdAndDate_returnsMatchingLog() async throws {
        // given
        let targetDate = makeDay(year: 2026, month: 5, day: 1)
        let targetId = UUID()
        let otherId = UUID()

        repository.logs = [
            makeLog(medicationId: targetId, date: targetDate),
            makeLog(medicationId: otherId, date: targetDate),
        ]

        // when
        let result = try await sut.fetch(medicationId: targetId, date: targetDate)

        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.medicationId, targetId)
    }
}

// MARK: - Helpers

private extension MedicationLogUseCaseTests {
    func makeLog(medicationId: UUID, date: Date) -> MedicationLog {
        MedicationLog(
            id: UUID(),
            medicationId: medicationId,
            logDate: date,
            isTaken: true,
            timeSlotID: UUID()
        )
    }

    func makeDay(year: Int, month: Int, day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }
}
