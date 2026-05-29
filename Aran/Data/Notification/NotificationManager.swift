import Foundation
import UserNotifications

final class NotificationManager: NotificationRepositoryProtocol {
    private let center = UNUserNotificationCenter.current()

    func schedule(for medication: Medication) async throws -> [String] {
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        guard granted else { throw AppError.notificationError(NotificationError.permissionDenied) }

        var ids: [String] = []
        for slot in medication.schedule.timeSlots where slot.isEnabled {
            let id = slot.id.uuidString
            let content = UNMutableNotificationContent()
            content.title = "복약 알림"
            content.body = "복용 시간입니다. 앱에서 상세 내용을 확인하세요."
            content.sound = .default

            let components = Calendar.current.dateComponents([.hour, .minute], from: slot.time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            try await center.add(request)
            ids.append(id)
        }
        return ids
    }

    func cancel(notificationIDs: [String]) async throws {
        center.removePendingNotificationRequests(withIdentifiers: notificationIDs)
    }

    func cancelAll() async throws {
        center.removeAllPendingNotificationRequests()
    }
}

private enum NotificationError: Error {
    case permissionDenied
}
