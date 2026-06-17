import Foundation
import AranDomain

enum HealthRecordMapper {
    static func toDomain(_ model: HealthRecordModel) -> HealthRecord {
        HealthRecord(
            id: model.id,
            type: model.type,
            value: model.value,
            unit: model.unit,
            recordDate: model.recordDate,
            memo: model.memo
        )
    }

    static func toModel(_ entity: HealthRecord) -> HealthRecordModel {
        HealthRecordModel(
            id: entity.id,
            type: entity.type,
            value: entity.value,
            unit: entity.unit,
            recordDate: entity.recordDate,
            memo: entity.memo
        )
    }
}
