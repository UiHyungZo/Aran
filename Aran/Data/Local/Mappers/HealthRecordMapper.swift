import Foundation

enum HealthRecordMapper {
    static func toDomain(_ model: HealthRecordModel) -> HealthRecord {
        HealthRecord(
            id: model.id,
            testItem: TestItem(rawValue: model.testItemRawValue) ?? .fsh,
            value: model.value,
            date: model.date,
            note: model.note
        )
    }

    static func toModel(_ entity: HealthRecord) -> HealthRecordModel {
        HealthRecordModel(
            id: entity.id,
            testItemRawValue: entity.testItem.rawValue,
            value: entity.value,
            date: entity.date,
            note: entity.note
        )
    }
}
