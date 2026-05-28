import Foundation

enum MedicationLegacySlotID {
    static func make(medicationID: UUID, index: Int) -> UUID {
        let sanitized = medicationID.uuidString.replacingOccurrences(of: "-", with: "")
        let indexHex = String(format: "%08X", max(index, 0))
        let mergedHex = String(sanitized.prefix(24)) + indexHex
        return uuidFromHex(mergedHex) ?? UUID()
    }

    private static func uuidFromHex(_ hex: String) -> UUID? {
        guard hex.count == 32 else { return nil }
        let p1 = hex.prefix(8)
        let p2 = hex.dropFirst(8).prefix(4)
        let p3 = hex.dropFirst(12).prefix(4)
        let p4 = hex.dropFirst(16).prefix(4)
        let p5 = hex.dropFirst(20).prefix(12)
        return UUID(uuidString: "\(p1)-\(p2)-\(p3)-\(p4)-\(p5)")
    }
}
