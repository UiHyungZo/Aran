import Foundation

public struct MedicationTimeSlot: Identifiable, Hashable {
    public let id: UUID
    public var time: Date
    public var isEnabled: Bool
    public var medicationID: UUID

    public init(id: UUID, time: Date, isEnabled: Bool, medicationID: UUID) {
        self.id = id
        self.time = time
        self.isEnabled = isEnabled
        self.medicationID = medicationID
    }
}
