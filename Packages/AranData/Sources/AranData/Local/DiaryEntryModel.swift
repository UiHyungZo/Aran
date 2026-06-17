import Foundation
import SwiftData
import AranDomain

@Model
public final class DiaryEntryModel {
    @Attribute(.unique) public var id: UUID
    public var date: Date
    public var emoji: String?
    public var content: String

    public init(id: UUID = UUID(), date: Date, emoji: String? = nil, content: String) {
        self.id = id
        self.date = date
        self.emoji = emoji
        self.content = content
    }
}
