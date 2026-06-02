import Foundation
import SwiftData

@Model
final class RecentDrugSearchModel {
    @Attribute(.unique) var keyword: String
    var id: UUID
    var createdAt: Date

    init(id: UUID = UUID(), keyword: String, createdAt: Date = Date()) {
        self.id = id
        self.keyword = keyword
        self.createdAt = createdAt
    }
}
