import Foundation
import SwiftData

@Model
final class DiaryEntryModel {
    @Attribute(.unique) var id: UUID
    var date: Date
    var emoji: String?
    var content: String

    init(id: UUID = UUID(), date: Date, emoji: String? = nil, content: String) {
        self.id = id
        self.date = date
        self.emoji = emoji
        self.content = content
    }
}
