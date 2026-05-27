import Foundation

enum PGTRecordMapper {
    static func toDomain(_ model: PGTRecordModel) -> PGTRecord {
        PGTRecord(
            id: model.id,
            cycleRecordId: model.cycleRecordId,
            testDate: model.testDate,
            type: PGTType(rawValue: model.typeRawValue) ?? .pgtA,
            normalCount: model.normalCount,
            abnormalCount: model.abnormalCount,
            mosaicCount: model.mosaicCount,
            memo: model.memo
        )
    }

    static func toModel(_ entity: PGTRecord) -> PGTRecordModel {
        PGTRecordModel(
            id: entity.id,
            cycleRecordId: entity.cycleRecordId,
            testDate: entity.testDate,
            typeRawValue: entity.type.rawValue,
            normalCount: entity.normalCount,
            abnormalCount: entity.abnormalCount,
            mosaicCount: entity.mosaicCount,
            memo: entity.memo
        )
    }
}
