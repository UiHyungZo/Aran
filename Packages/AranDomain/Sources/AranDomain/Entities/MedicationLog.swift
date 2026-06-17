import Foundation

public struct MedicationLog: Identifiable {
    public let id: UUID
    public var medicationId: UUID
    public var logDate: Date
    public var isTaken: Bool
    public var timeSlotID: UUID

    public init(id: UUID, medicationId: UUID, logDate: Date, isTaken: Bool, timeSlotID: UUID) {
        self.id = id
        self.medicationId = medicationId
        self.logDate = logDate
        self.isTaken = isTaken
        self.timeSlotID = timeSlotID
    }
}
