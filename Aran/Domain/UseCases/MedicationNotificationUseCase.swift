import Foundation

final class MedicationNotificationUseCase {
    private let notificationRepository: NotificationRepositoryProtocol

    init(notificationRepository: NotificationRepositoryProtocol) {
        self.notificationRepository = notificationRepository
    }

    func prepareForSave(_ medication: Medication) async throws -> Medication {
        var updated = medication
        guard medication.isEnabled else {
            updated.notificationIDs = []
            return updated
        }
        updated.notificationIDs = try await notificationRepository.schedule(for: medication)
        return updated
    }

    func enable(_ medication: Medication) async throws -> Medication {
        var updated = medication
        updated.isEnabled = true
        updated.notificationIDs = try await notificationRepository.schedule(for: updated)
        return updated
    }

    func disable(_ medication: Medication) async throws -> Medication {
        var updated = medication
        updated.isEnabled = false
        try await notificationRepository.cancel(notificationIDs: medication.notificationIDs)
        updated.notificationIDs = []
        return updated
    }

    func cancel(for medication: Medication) async throws {
        guard !medication.notificationIDs.isEmpty else { return }
        try await notificationRepository.cancel(notificationIDs: medication.notificationIDs)
    }
}
