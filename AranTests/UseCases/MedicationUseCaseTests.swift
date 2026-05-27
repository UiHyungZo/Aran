@testable import Aran
import XCTest

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
}
