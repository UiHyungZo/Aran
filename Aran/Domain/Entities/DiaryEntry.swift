import Foundation

struct DiaryEntry: Identifiable {
    let id: UUID
    var date: Date
    var emoji: String?
    var content: String

    init(id: UUID = UUID(), date: Date = Date(), emoji: String? = nil, content: String) {
        self.id = id
        self.date = date
        self.emoji = emoji
        self.content = content
    }

    var text: String {
        get { content }
        set { content = newValue }
    }
}
