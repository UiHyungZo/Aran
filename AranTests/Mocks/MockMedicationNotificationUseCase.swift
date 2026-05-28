@testable import Aran
import Foundation

final class MockMedicationNotificationUseCase: MedicationNotificationUseCaseProtocol {
    var shouldThrow: Error?

    func prepareForSave(_ medication: Medication) async throws -> Medication {
        if let error = shouldThrow { throw error }
        return medication
    }

    func prepareForUpdate(_ medication: Medication) async throws -> Medication {
        if let error = shouldThrow { throw error }
        return medication
    }

    func enable(_ medication: Medication) async throws -> Medication {
        if let error = shouldThrow { throw error }
        var updated = medication
        updated.isEnabled = true
        return updated
    }

    func disable(_ medication: Medication) async throws -> Medication {
        if let error = shouldThrow { throw error }
        var updated = medication
        updated.isEnabled = false
        return updated
    }

    func cancel(for medication: Medication) async throws {
        if let error = shouldThrow { throw error }
    }
}
