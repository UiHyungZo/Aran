import Foundation
import UserNotifications
import AranDomain

public final class NotificationManager: NotificationRepositoryProtocol {
    private let center = UNUserNotificationCenter.current()

    public init() {}

    public func schedule(for medication: Medication) async throws -> [String] {
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        guard granted else { throw AppError.notificationError(NotificationError.permissionDenied) }

        var ids: [String] = []
        for slot in medication.schedule.timeSlots where slot.isEnabled {
            let id = slot.id.uuidString
            let content = UNMutableNotificationContent()
            content.title = "복약 알림"
            content.body = "\(medication.drugName) \(medication.dosage) 복용 시간입니다."
            content.sound = .default

            let components = Calendar.current.dateComponents([.hour, .minute], from: slot.time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            try await center.add(request)
            ids.append(id)
        }
        return ids
    }

    public func cancel(notificationIDs: [String]) async throws {
        center.removePendingNotificationRequests(withIdentifiers: notificationIDs)
    }

    public func cancelAll() async throws {
        center.removeAllPendingNotificationRequests()
    }

    public func permissionStatus() async -> NotificationPermissionStatus {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined: return .notDetermined
        case .authorized:    return .authorized
        case .denied:        return .denied
        case .provisional:   return .provisional
        case .ephemeral:     return .ephemeral
        @unknown default:    return .notDetermined
        }
    }
}

private enum NotificationError: Error {
    case permissionDenied
}
