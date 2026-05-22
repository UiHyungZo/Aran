@testable import Aran
import Foundation

final class MockNotificationRepository: NotificationRepositoryProtocol {
    var scheduledMedications: [Medication] = []
    var cancelledIDs: [String] = []
    var cancelAllCalled = false
    var scheduleResult: [String] = ["mock-notification-id"]
    var shouldThrow: Error?

    func schedule(for medication: Medication) async throws -> [String] {
        if let error = shouldThrow { throw error }
        scheduledMedications.append(medication)
        return scheduleResult
    }

    func cancel(notificationIDs: [String]) async throws {
        if let error = shouldThrow { throw error }
        cancelledIDs.append(contentsOf: notificationIDs)
    }

    func cancelAll() async throws {
        if let error = shouldThrow { throw error }
        cancelAllCalled = true
    }
}
