import Foundation

struct Medication: Identifiable {
    let id: UUID
    var drugName: String
    var dosage: String
    var type: MedicationType
    var schedule: MedicationSchedule
    var isEnabled: Bool
    var notificationIDs: [String]
    var createdAt: Date
}

enum MedicationType: String, CaseIterable {
    case oral = "경구"
    case injection = "주사"
    case patch = "패치"
    case other = "기타"
}

struct MedicationSchedule {
    var times: [Date]
    var startDate: Date
    var endDate: Date?
}
