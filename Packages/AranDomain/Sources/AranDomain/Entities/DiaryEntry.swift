import Foundation

public struct DiaryEntry: Identifiable {
    public let id: UUID
    public var date: Date
    public var emoji: String?
    public var content: String

    public init(id: UUID, date: Date = Date(), emoji: String? = nil, content: String) {
        self.id = id
        self.date = date
        self.emoji = emoji
        self.content = content
    }

    public var text: String {
        get { content }
        set { content = newValue }
    }
}
