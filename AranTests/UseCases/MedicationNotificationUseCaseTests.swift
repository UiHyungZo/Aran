@testable import Aran
import XCTest

final class MedicationNotificationUseCaseTests: XCTestCase {
    private var repository: MockNotificationRepository!
    private var sut: MedicationNotificationUseCase!

    override func setUp() {
        super.setUp()
        repository = MockNotificationRepository()
        sut = MedicationNotificationUseCase(notificationRepository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func testPrepareForSave_whenEnabled_schedulesAndStoresIDs() async throws {
        repository.scheduleResult = ["id-1", "id-2"]
        let medication = makeMedication(isEnabled: true)

        let result = try await sut.prepareForSave(medication)

        XCTAssertEqual(repository.scheduledMedications.count, 1)
        XCTAssertEqual(result.notificationIDs, ["id-1", "id-2"])
    }

    func testPrepareForSave_whenDisabled_doesNotSchedule() async throws {
        let medication = makeMedication(isEnabled: false, notificationIDs: ["old"])

        let result = try await sut.prepareForSave(medication)

        XCTAssertTrue(repository.scheduledMedications.isEmpty)
        XCTAssertTrue(result.notificationIDs.isEmpty)
    }

    func testEnable_schedulesNotificationAndMarksEnabled() async throws {
        repository.scheduleResult = ["new-id"]
        let medication = makeMedication(isEnabled: false)

        let result = try await sut.enable(medication)

        XCTAssertTrue(result.isEnabled)
        XCTAssertEqual(result.notificationIDs, ["new-id"])
        XCTAssertEqual(repository.scheduledMedications.count, 1)
    }

    func testDisable_cancelsExistingNotificationsAndClearsIDs() async throws {
        let medication = makeMedication(isEnabled: true, notificationIDs: ["old-id"])

        let result = try await sut.disable(medication)

        XCTAssertFalse(result.isEnabled)
        XCTAssertEqual(repository.cancelledIDs, ["old-id"])
        XCTAssertTrue(result.notificationIDs.isEmpty)
    }

    func testCancel_withNotificationIDs_cancelsExistingNotifications() async throws {
        let medication = makeMedication(notificationIDs: ["id-1"])

        try await sut.cancel(for: medication)

        XCTAssertEqual(repository.cancelledIDs, ["id-1"])
    }

    func testCancel_withNoNotificationIDs_skipsRepositoryCall() async throws {
        let medication = makeMedication(notificationIDs: [])

        try await sut.cancel(for: medication)

        XCTAssertTrue(repository.cancelledIDs.isEmpty)
    }
}

private extension MedicationNotificationUseCaseTests {
    func makeMedication(
        isEnabled: Bool = true,
        notificationIDs: [String] = []
    ) -> Medication {
        Medication(
            id: UUID(),
            drugName: "테스트약",
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
