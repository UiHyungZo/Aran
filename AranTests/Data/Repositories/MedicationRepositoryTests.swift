@testable import Aran
import SwiftData
import XCTest
import AranDomain

final class MedicationRepositoryTests: XCTestCase {
    private var container: ModelContainer!
    private var sut: MedicationRepository!

    override func setUp() async throws {
        try await super.setUp()
        let schema = Schema([MedicationModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: config)
        sut = MedicationRepository(context: ModelContext(container))
    }

    override func tearDown() async throws {
        sut = nil
        container = nil
        try await super.tearDown()
    }

    func test_save_whenMedicationIsValid_thenFetchAllContainsIt() async throws {
        // given
        let medication = makeMedication(name: "프로게스테론")

        // when
        try await sut.save(medication)
        let result = try await sut.fetchAll()

        // then
        XCTAssertTrue(result.contains { $0.drugName == "프로게스테론" })
    }

    func test_delete_whenMedicationExists_thenRemovedFromList() async throws {
        // given
        let medication = makeMedication(name: "삭제할약")
        try await sut.save(medication)

        // when
        try await sut.delete(id: medication.id)
        let result = try await sut.fetchAll()

        // then
        XCTAssertFalse(result.contains { $0.id == medication.id })
    }

    func test_update_whenMedicationExists_thenValuesAreUpdated() async throws {
        // given
        let medication = makeMedication(name: "원래약")
        try await sut.save(medication)

        // when
        var updated = medication
        updated = Medication(
            id: medication.id,
            drugName: "수정된약",
            dosage: medication.dosage,
            type: medication.type,
            schedule: medication.schedule,
            isEnabled: medication.isEnabled,
            notificationIDs: medication.notificationIDs,
            createdAt: medication.createdAt
        )
        try await sut.update(updated)
        let result = try await sut.fetchAll()

        // then
        XCTAssertTrue(result.contains { $0.drugName == "수정된약" })
        XCTAssertFalse(result.contains { $0.drugName == "원래약" })
    }
}

// MARK: - Helpers

private extension MedicationRepositoryTests {
    func makeMedication(name: String = "테스트약") -> Medication {
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
            isEnabled: true,
            notificationIDs: [],
            createdAt: Date()
        )
    }
}
