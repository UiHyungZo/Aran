import Foundation
import AranDomain

public enum TransferRecordMapper {
    public static func toDomain(_ model: TransferRecordModel) -> TransferRecord {
        TransferRecord(
            id: model.id,
            cycleNumber: model.cycleNumber,
            date: model.date,
            embryoGrade: model.embryoGrade,
            embryoCount: model.embryoCount,
            transferType: TransferType(rawValue: model.transferTypeRawValue) ?? .fresh,
            result: TransferResult(rawValue: model.resultRawValue) ?? .waiting,
            memo: model.memo
        )
    }

    public static func toModel(_ entity: TransferRecord) -> TransferRecordModel {
        TransferRecordModel(
            id: entity.id,
            cycleNumber: entity.cycleNumber,
            date: entity.date,
            embryoGrade: entity.embryoGrade,
            embryoCount: entity.embryoCount,
            transferTypeRawValue: entity.transferType.rawValue,
            resultRawValue: entity.result.rawValue,
            memo: entity.memo
        )
    }
}
