import Foundation

final class MedicationUseCase {
    private let medicationRepository: MedicationRepositoryProtocol
    private let notificationUseCase: MedicationNotificationUseCase

    init(
        medicationRepository: MedicationRepositoryProtocol,
        notificationUseCase: MedicationNotificationUseCase
    ) {
        self.medicationRepository = medicationRepository
        self.notificationUseCase = notificationUseCase
    }

    convenience init(
        medicationRepository: MedicationRepositoryProtocol,
        notificationRepository: NotificationRepositoryProtocol
    ) {
        self.init(
            medicationRepository: medicationRepository,
            notificationUseCase: MedicationNotificationUseCase(notificationRepository: notificationRepository)
        )
    }

    func fetchAll() async throws -> [Medication] {
        return try await medicationRepository.fetchAll()
    }

    func save(_ medication: Medication) async throws {
        let updated = try await notificationUseCase.prepareForSave(medication)
        try await medicationRepository.save(updated)
    }

    func update(_ medication: Medication) async throws {
        let updated = try await notificationUseCase.prepareForUpdate(medication)
        try await medicationRepository.update(updated)
    }

    func toggle(medication: Medication) async throws {
        let updated: Medication
        if medication.isEnabled {
            updated = try await notificationUseCase.disable(medication)
        } else {
            updated = try await notificationUseCase.enable(medication)
        }
        try await medicationRepository.update(updated)
    }

    func delete(medication: Medication) async throws {
        try await notificationUseCase.cancel(for: medication)
        try await medicationRepository.delete(id: medication.id)
    }
}
