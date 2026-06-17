@testable import Aran
import XCTest
import AranDomain
import AranData

final class MedicationMapperTests: XCTestCase {

    func test_toDomain_whenModelIsValid_thenAllFieldsMapped() {
        // given
        let id = UUID()
        let createdAt = Date()
        let startDate = Date()
        let model = MedicationModel(
            id: id,
            drugName: "프로게스테론",
            dosage: "100mg",
            typeRawValue: "경구",
            scheduleTimes: [],
            scheduleStartDate: startDate,
            scheduleEndDate: nil,
            isEnabled: true,
            notificationIDs: ["nid-1"],
            createdAt: createdAt
        )

        // when
        let medication = MedicationMapper.toDomain(model)

        // then
        XCTAssertEqual(medication.id, id)
        XCTAssertEqual(medication.drugName, "프로게스테론")
        XCTAssertEqual(medication.dosage, "100mg")
        XCTAssertEqual(medication.type, .oral)
        XCTAssertTrue(medication.isEnabled)
        XCTAssertEqual(medication.notificationIDs, ["nid-1"])
    }

    func test_toDomain_whenSchedulePresent_thenScheduleIsMapped() {
        // given
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)
        let times = [Date(), Date()]
        let model = MedicationModel(
            id: UUID(),
            drugName: "테스트약",
            dosage: "50mg",
            typeRawValue: "주사",
            scheduleTimes: times,
            scheduleStartDate: startDate,
            scheduleEndDate: endDate,
            isEnabled: false,
            notificationIDs: [],
            createdAt: Date()
        )

        // when
        let medication = MedicationMapper.toDomain(model)

        // then
        XCTAssertEqual(medication.schedule.times.count, 2)
        XCTAssertEqual(medication.schedule.startDate, startDate)
        XCTAssertEqual(medication.schedule.endDate, endDate)
    }

    func test_toModel_whenEntityIsValid_thenAllFieldsMapped() {
        // given
        let id = UUID()
        let createdAt = Date()
        let entity = Medication(
            id: id,
            drugName: "에스트라디올",
            dosage: "2mg",
            type: .patch,
            schedule: MedicationSchedule(times: [Date()], startDate: Date(), endDate: nil),
            isEnabled: false,
            notificationIDs: [],
            createdAt: createdAt
        )

        // when
        let model = MedicationMapper.toModel(entity)

        // then
        XCTAssertEqual(model.id, id)
        XCTAssertEqual(model.drugName, "에스트라디올")
        XCTAssertEqual(model.dosage, "2mg")
        XCTAssertEqual(model.typeRawValue, "패치")
        XCTAssertFalse(model.isEnabled)
    }

    func test_toModel_thenIsEnabledPreserved() {
        // given
        let enabledEntity = Medication(
            id: UUID(),
            drugName: "약A",
            dosage: "1정",
            type: .oral,
            schedule: MedicationSchedule(times: [], startDate: Date(), endDate: nil),
            isEnabled: true,
            notificationIDs: ["id-1"],
            createdAt: Date()
        )

        // when
        let model = MedicationMapper.toModel(enabledEntity)

        // then
        XCTAssertTrue(model.isEnabled)
        XCTAssertEqual(model.notificationIDs, ["id-1"])
    }
}
