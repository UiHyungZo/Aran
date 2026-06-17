@testable import Aran
import XCTest
import AranDomain

final class MedicationLogMapperTests: XCTestCase {

    func test_toDomain_whenModelHasTimeSlotID_thenAllFieldsMapped() {
        // given
        let id = UUID()
        let medicationId = UUID()
        let timeSlotID = UUID()
        let date = Date()
        let model = MedicationLogModel(
            id: id,
            medicationId: medicationId,
            logDate: date,
            isTaken: true,
            timeSlotID: timeSlotID
        )

        // when
        let log = MedicationLogMapper.toDomain(model)

        // then
        XCTAssertEqual(log.id, id)
        XCTAssertEqual(log.medicationId, medicationId)
        XCTAssertEqual(log.logDate, date)
        XCTAssertTrue(log.isTaken)
        XCTAssertEqual(log.timeSlotID, timeSlotID)
    }

    func test_toDomain_whenModelHasLegacyTimeIndex_thenBuildsStableTimeSlotID() {
        // given
        let medicationId = UUID()
        let model = MedicationLogModel(
            medicationId: medicationId,
            logDate: Date(),
            isTaken: false,
            timeSlotID: nil,
            timeIndex: 2
        )
        let expectedSlotID = MedicationLegacySlotID.make(medicationID: medicationId, index: 2)

        // when
        let log = MedicationLogMapper.toDomain(model)

        // then
        XCTAssertEqual(log.timeSlotID, expectedSlotID)
        XCTAssertFalse(log.isTaken)
    }

    func test_toModel_whenEntityIsValid_thenAllFieldsMapped() {
        // given
        let log = MedicationLog(
            id: UUID(),
            medicationId: UUID(),
            logDate: Date(),
            isTaken: true,
            timeSlotID: UUID()
        )

        // when
        let model = MedicationLogMapper.toModel(log)

        // then
        XCTAssertEqual(model.id, log.id)
        XCTAssertEqual(model.medicationId, log.medicationId)
        XCTAssertEqual(model.logDate, log.logDate)
        XCTAssertTrue(model.isTaken)
        XCTAssertEqual(model.timeSlotID, log.timeSlotID)
    }
}
