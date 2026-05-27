import Foundation

struct HospitalVisit: Identifiable {
    let id: UUID
    var visitDate: Date
    var visitTypes: [String]
    var memo: String?
}
