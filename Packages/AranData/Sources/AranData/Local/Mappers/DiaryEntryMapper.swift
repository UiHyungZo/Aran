import Foundation
import AranDomain

public enum DiaryEntryMapper {
    public static func toDomain(_ model: DiaryEntryModel) -> DiaryEntry {
        DiaryEntry(id: model.id, date: model.date, emoji: model.emoji, content: model.content)
    }

    public static func toModel(_ entity: DiaryEntry) -> DiaryEntryModel {
        DiaryEntryModel(id: entity.id, date: entity.date, emoji: entity.emoji, content: entity.content)
    }
}
