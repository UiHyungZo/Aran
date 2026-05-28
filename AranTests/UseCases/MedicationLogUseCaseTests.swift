@testable import Aran
import XCTest

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
        let timeIndex = 0

        // when
        try await sut.toggle(medicationId: medicationId, date: date, timeIndex: timeIndex)

        // then
        let log = try await repository.fetch(medicationId: medicationId, date: date, timeIndex: timeIndex)
        XCTAssertEqual(log?.isTaken, true)
        XCTAssertEqual(log?.timeIndex, timeIndex)
    }

    func test_toggle_whenLogExists_thenTogglesTakenState() async throws {
        // given
        let medicationId = UUID()
        let date = Date()
        let timeIndex = 0
        try await repository.upsert(MedicationLog(
            id: UUID(),
            medicationId: medicationId,
            logDate: date,
            isTaken: true,
            timeIndex: timeIndex
        ))

        // when
        try await sut.toggle(medicationId: medicationId, date: date, timeIndex: timeIndex)

        // then
        let log = try await repository.fetch(medicationId: medicationId, date: date, timeIndex: timeIndex)
        XCTAssertEqual(log?.isTaken, false)
    }

    func test_toggle_whenSameMedicationAndDate_thenDoesNotCreateDuplicateLog() async throws {
        // given
        let medicationId = UUID()
        let date = Date()
        let timeIndex = 0

        // when
        try await sut.toggle(medicationId: medicationId, date: date, timeIndex: timeIndex)
        try await sut.toggle(medicationId: medicationId, date: date, timeIndex: timeIndex)

        // then
        XCTAssertEqual(repository.logs.count, 1)
    }
}
