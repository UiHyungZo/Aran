@testable import Aran
import XCTest
import AranDomain

final class MedicationUseCaseTests: XCTestCase {
    private var medicationRepo: MockMedicationRepository!
    private var notificationRepo: MockNotificationRepository!
    private var sut: MedicationUseCase!

    override func setUp() {
        super.setUp()
        medicationRepo = MockMedicationRepository()
        notificationRepo = MockNotificationRepository()
        sut = MedicationUseCase(
            medicationRepository: medicationRepo,
            notificationRepository: notificationRepo
        )
    }

    override func tearDown() {
        sut = nil
        medicationRepo = nil
        notificationRepo = nil
        super.tearDown()
    }

    // MARK: - fetchAll

    func testFetchAll_returnsMedications() async throws {
        // given
        let expected = [makeMedication(name: "프로게스테론")]
        medicationRepo.fetchAllResult = expected

        // when
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.map(\.drugName), expected.map(\.drugName))
    }

    // MARK: - save

    func testSave_whenEnabled_schedulesNotification() async throws {
        // given
        let medication = makeMedication(isEnabled: true)

        // when
        try await sut.save(medication)

        // then
        XCTAssertEqual(notificationRepo.scheduledMedications.count, 1)
    }

    func testSave_whenEnabled_storesNotificationIDs() async throws {
        // given
        notificationRepo.scheduleResult = ["id-1", "id-2"]
        let medication = makeMedication(isEnabled: true)

        // when
        try await sut.save(medication)

        // then
        let saved = medicationRepo.savedMedications.first
        XCTAssertEqual(saved?.notificationIDs, ["id-1", "id-2"])
    }

    func testSave_whenDisabled_skipsNotification() async throws {
        // given
        let medication = makeMedication(isEnabled: false)

        // when
        try await sut.save(medication)

        // then
        XCTAssertTrue(notificationRepo.scheduledMedications.isEmpty)
        XCTAssertEqual(medicationRepo.savedMedications.count, 1)
    }

    // MARK: - update

    func testUpdate_whenEnabled_cancelsOldNotificationAndSchedulesNewNotification() async throws {
        // given
        notificationRepo.scheduleResult = ["new-id"]
        let medication = makeMedication(isEnabled: true, notificationIDs: ["old-id"])

        // when
        try await sut.update(medication)

        // then
        XCTAssertEqual(notificationRepo.cancelledIDs, ["old-id"])
        XCTAssertEqual(notificationRepo.scheduledMedications.count, 1)
        XCTAssertEqual(medicationRepo.updatedMedications.first?.notificationIDs, ["new-id"])
    }

    func testUpdate_whenDisabled_cancelsOldNotificationAndClearsIDs() async throws {
        // given
        let medication = makeMedication(isEnabled: false, notificationIDs: ["old-id"])

        // when
        try await sut.update(medication)

        // then
        XCTAssertEqual(notificationRepo.cancelledIDs, ["old-id"])
        XCTAssertTrue(notificationRepo.scheduledMedications.isEmpty)
        XCTAssertEqual(medicationRepo.updatedMedications.first?.notificationIDs, [])
    }

    // MARK: - toggle

    func testToggle_fromEnabledToDisabled_cancelsNotification() async throws {
        // given
        let medication = makeMedication(isEnabled: true, notificationIDs: ["nid-1"])

        // when
        try await sut.toggle(medication: medication)

        // then
        XCTAssertEqual(notificationRepo.cancelledIDs, ["nid-1"])
        XCTAssertTrue(notificationRepo.scheduledMedications.isEmpty)
    }

    func testToggle_fromEnabledToDisabled_clearsNotificationIDs() async throws {
        // given
        let medication = makeMedication(isEnabled: true, notificationIDs: ["nid-1"])

        // when
        try await sut.toggle(medication: medication)

        // then
        let updated = medicationRepo.updatedMedications.first
        XCTAssertEqual(updated?.notificationIDs, [])
    }

    func testToggle_fromDisabledToEnabled_schedulesNotification() async throws {
        // given
        notificationRepo.scheduleResult = ["new-id"]
        let medication = makeMedication(isEnabled: false)

        // when
        try await sut.toggle(medication: medication)

        // then
        XCTAssertEqual(notificationRepo.scheduledMedications.count, 1)
        XCTAssertEqual(medicationRepo.updatedMedications.first?.notificationIDs, ["new-id"])
    }

    // MARK: - toggleTimeSlot

    func testToggleTimeSlot_whenBothSlotsEnabled_keepsMedicationEnabled() async throws {
        // given
        let medicationId = UUID()
        let slot1 = MedicationTimeSlot(id: UUID(), time: makeTime(hour: 9), isEnabled: true, medicationID: medicationId)
        let slot2 = MedicationTimeSlot(id: UUID(), time: makeTime(hour: 21), isEnabled: true, medicationID: medicationId)
        let medication = makeMedicationWithSlots(id: medicationId, slots: [slot1, slot2], isEnabled: true)

        // when
        try await sut.toggleTimeSlot(medication: medication, timeSlotID: slot1.id)

        // then
        let updated = medicationRepo.updatedMedications.first
        XCTAssertEqual(updated?.schedule.timeSlots.first(where: { $0.id == slot1.id })?.isEnabled, false)
        XCTAssertTrue(updated?.isEnabled ?? false, "slot2가 enabled이므로 medication.isEnabled는 true를 유지해야 한다")
    }

    func testToggleTimeSlot_whenLastEnabledSlot_setsMedicationDisabled() async throws {
        // given
        let medicationId = UUID()
        let slot1 = MedicationTimeSlot(id: UUID(), time: makeTime(hour: 9), isEnabled: true, medicationID: medicationId)
        let slot2 = MedicationTimeSlot(id: UUID(), time: makeTime(hour: 21), isEnabled: false, medicationID: medicationId)
        let medication = makeMedicationWithSlots(id: medicationId, slots: [slot1, slot2], isEnabled: true)

        // when
        try await sut.toggleTimeSlot(medication: medication, timeSlotID: slot1.id)

        // then
        let updated = medicationRepo.updatedMedications.first
        XCTAssertFalse(updated?.isEnabled ?? true, "마지막 enabled 슬롯을 끄면 medication.isEnabled가 false여야 한다")
        XCTAssertEqual(updated?.schedule.timeSlots.first(where: { $0.id == slot2.id })?.isEnabled, false)
    }

    func testToggleTimeSlot_withUnknownID_throwsError() async throws {
        // given
        let medication = makeMedication()

        // when / then
        do {
            try await sut.toggleTimeSlot(medication: medication, timeSlotID: UUID())
            XCTFail("존재하지 않는 슬롯 ID로 호출 시 에러가 발생해야 한다")
        } catch {
            // expected
        }
    }

    // MARK: - delete

    func testDelete_cancelsNotificationAndDeletesFromRepo() async throws {
        // given
        let medication = makeMedication(isEnabled: true, notificationIDs: ["del-id"])

        // when
        try await sut.delete(medication: medication)

        // then
        XCTAssertEqual(notificationRepo.cancelledIDs, ["del-id"])
        XCTAssertEqual(medicationRepo.deletedIDs, [medication.id])
    }

    func testDelete_withNoNotifications_stillDeletesFromRepo() async throws {
        // given
        let medication = makeMedication(isEnabled: false, notificationIDs: [])

        // when
        try await sut.delete(medication: medication)

        // then
        XCTAssertTrue(notificationRepo.cancelledIDs.isEmpty)
        XCTAssertEqual(medicationRepo.deletedIDs, [medication.id])
    }
}

// MARK: - Helpers

private extension MedicationUseCaseTests {
    func makeMedication(
        name: String = "테스트약",
        isEnabled: Bool = false,
        notificationIDs: [String] = []
    ) -> Medication {
        Medication(
            id: UUID(),
            drugName: name,
            dosage: "100mg",
            type: .oral,
            schedule: MedicationSchedule(
                times: [Date()],
                startDate: Date(),
                endDate: nil
            ),
            isEnabled: isEnabled,
            notificationIDs: notificationIDs,
            createdAt: Date()
        )
    }

    func makeMedicationWithSlots(
        id: UUID = UUID(),
        slots: [MedicationTimeSlot],
        isEnabled: Bool = true,
        notificationIDs: [String] = []
    ) -> Medication {
        Medication(
            id: id,
            drugName: "테스트약",
            dosage: "100mg",
            type: .oral,
            schedule: MedicationSchedule(timeSlots: slots, startDate: Date(), endDate: nil),
            isEnabled: isEnabled,
            notificationIDs: notificationIDs,
            createdAt: Date()
        )
    }

    func makeTime(hour: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
    }
}
