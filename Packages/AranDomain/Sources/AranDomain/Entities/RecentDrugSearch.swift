import Foundation

public struct RecentDrugSearch: Identifiable, Equatable {
    public let id: UUID
    public let keyword: String
    public let createdAt: Date

    public init(id: UUID = UUID(), keyword: String, createdAt: Date = Date()) {
        self.id = id
        self.keyword = keyword
        self.createdAt = createdAt
    }
}
