import Foundation

enum HealthRecordMapper {
    static func toDomain(_ model: HealthRecordModel) -> HealthRecord {
        let pgtResult: PGTResult?
        if let normal = model.pgtNormal,
           let abnormal = model.pgtAbnormal,
           let mosaic = model.pgtMosaic
        {
            pgtResult = PGTResult(normal: normal, abnormal: abnormal, mosaic: mosaic)
        } else {
            pgtResult = nil
        }

        return HealthRecord(
            id: model.id,
            testItem: TestItem(rawValue: model.testItemRawValue) ?? .fsh,
            value: model.value,
            date: model.date,
            note: model.note,
            pgtResult: pgtResult
        )
    }

    static func toModel(_ entity: HealthRecord) -> HealthRecordModel {
        HealthRecordModel(
            id: entity.id,
            testItemRawValue: entity.testItem.rawValue,
            value: entity.value,
            date: entity.date,
            note: entity.note,
            pgtNormal: entity.pgtResult?.normal,
            pgtAbnormal: entity.pgtResult?.abnormal,
            pgtMosaic: entity.pgtResult?.mosaic
        )
    }
}
