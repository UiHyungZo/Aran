import Foundation

protocol MedicationNotificationUseCaseProtocol {
    func prepareForSave(_ medication: Medication) async throws -> Medication
    func prepareForUpdate(_ medication: Medication) async throws -> Medication
    func enable(_ medication: Medication) async throws -> Medication
    func disable(_ medication: Medication) async throws -> Medication
    func cancel(for medication: Medication) async throws
    func permissionStatus() async -> NotificationPermissionStatus
}

final class MedicationNotificationUseCase: MedicationNotificationUseCaseProtocol {
    private let notificationRepository: NotificationRepositoryProtocol

    init(notificationRepository: NotificationRepositoryProtocol) {
        self.notificationRepository = notificationRepository
    }

    func prepareForSave(_ medication: Medication) async throws -> Medication {
        var updated = medication
        guard medication.isEnabled else {
            updated.schedule.timeSlots = updated.schedule.timeSlots.map { slot in
                var mutable = slot
                mutable.isEnabled = false
                return mutable
            }
            updated.notificationIDs = []
            return updated
        }
        updated.notificationIDs = try await notificationRepository.schedule(for: medication)
        return updated
    }

    func prepareForUpdate(_ medication: Medication) async throws -> Medication {
        var updated = medication
        if !medication.notificationIDs.isEmpty {
            try await notificationRepository.cancel(notificationIDs: medication.notificationIDs)
        }

        guard medication.isEnabled else {
            updated.schedule.timeSlots = updated.schedule.timeSlots.map { slot in
                var mutable = slot
                mutable.isEnabled = false
                return mutable
            }
            updated.notificationIDs = []
            return updated
        }

        updated.notificationIDs = try await notificationRepository.schedule(for: medication)
        return updated
    }

    func enable(_ medication: Medication) async throws -> Medication {
        var updated = medication
        updated.isEnabled = true
        updated.schedule.timeSlots = updated.schedule.timeSlots.map { slot in
            var mutable = slot
            mutable.isEnabled = true
            return mutable
        }
        updated.notificationIDs = try await notificationRepository.schedule(for: updated)
        return updated
    }

    func disable(_ medication: Medication) async throws -> Medication {
        var updated = medication
        updated.isEnabled = false
        updated.schedule.timeSlots = updated.schedule.timeSlots.map { slot in
            var mutable = slot
            mutable.isEnabled = false
            return mutable
        }
        try await notificationRepository.cancel(notificationIDs: medication.notificationIDs)
        updated.notificationIDs = []
        return updated
    }

    func cancel(for medication: Medication) async throws {
        guard !medication.notificationIDs.isEmpty else { return }
        try await notificationRepository.cancel(notificationIDs: medication.notificationIDs)
    }

    func permissionStatus() async -> NotificationPermissionStatus {
        await notificationRepository.permissionStatus()
    }
}
