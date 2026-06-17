import Foundation
import SwiftData
import AranDomain

@Model
public final class MedicationTimeSlotModel {
    @Attribute(.unique) public var id: UUID
    public var time: Date
    public var isEnabled: Bool
    public var medication: MedicationModel?

    public init(
        id: UUID = UUID(),
        time: Date,
        isEnabled: Bool = true,
        medication: MedicationModel? = nil
    ) {
        self.id = id
        self.time = time
        self.isEnabled = isEnabled
        self.medication = medication
    }
}
