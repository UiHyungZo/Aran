import Foundation

protocol NotificationRepositoryProtocol {
    func schedule(for medication: Medication) async throws -> [String]
    func cancel(notificationIDs: [String]) async throws
    func cancelAll() async throws
}
