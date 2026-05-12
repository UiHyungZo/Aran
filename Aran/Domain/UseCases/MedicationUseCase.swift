import Foundation

final class MedicationUseCase {
    private let medicationRepository: MedicationRepositoryProtocol
    private let notificationRepository: NotificationRepositoryProtocol

    init(
        medicationRepository: MedicationRepositoryProtocol,
        notificationRepository: NotificationRepositoryProtocol
    ) {
        self.medicationRepository = medicationRepository
        self.notificationRepository = notificationRepository
    }

    func fetchAll() async throws -> [Medication] {
        return try await medicationRepository.fetchAll()
    }

    func save(_ medication: Medication) async throws {
        var updated = medication
        if medication.isEnabled {
            let ids = try await notificationRepository.schedule(for: medication)
            updated.notificationIDs = ids
        }
        try await medicationRepository.save(updated)
    }

    func toggle(medication: Medication) async throws {
        var updated = medication
        updated.isEnabled = !medication.isEnabled
        if updated.isEnabled {
            let ids = try await notificationRepository.schedule(for: updated)
            updated.notificationIDs = ids
        } else {
            try await notificationRepository.cancel(notificationIDs: medication.notificationIDs)
            updated.notificationIDs = []
        }
        try await medicationRepository.update(updated)
    }

    func delete(medication: Medication) async throws {
        try await notificationRepository.cancel(notificationIDs: medication.notificationIDs)
        try await medicationRepository.delete(id: medication.id)
    }
}
