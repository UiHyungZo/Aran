import Foundation

struct MedicationLog: Identifiable {
    let id: UUID
    var medicationId: UUID
    var logDate: Date
    var isTaken: Bool
    var timeSlotID: UUID
}
