import Foundation
import SwiftData

@Model
final class MedicationTimeSlotModel {
    @Attribute(.unique) var id: UUID
    var time: Date
    var isEnabled: Bool
    var medication: MedicationModel?

    init(
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
