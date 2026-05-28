import Foundation

struct MedicationTimeSlot: Identifiable, Hashable {
    let id: UUID
    var time: Date
    var isEnabled: Bool
    var medicationID: UUID
}
