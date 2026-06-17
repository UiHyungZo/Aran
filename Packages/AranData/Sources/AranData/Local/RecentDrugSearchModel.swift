import Foundation
import SwiftData
import AranDomain

@Model
public final class RecentDrugSearchModel {
    @Attribute(.unique) public var keyword: String
    public var id: UUID
    public var createdAt: Date

    public init(id: UUID = UUID(), keyword: String, createdAt: Date = Date()) {
        self.id = id
        self.keyword = keyword
        self.createdAt = createdAt
    }
}
