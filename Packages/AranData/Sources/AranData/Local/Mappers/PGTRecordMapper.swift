import Foundation
import AranDomain

public enum PGTRecordMapper {
    public static func toDomain(_ model: PGTRecordModel) -> PGTRecord {
        PGTRecord(
            id: model.id,
            cycleRecordId: model.cycleRecordId,
            testDate: model.testDate,
            type: PGTType(rawValue: model.typeRawValue) ?? .pgtA,
            normalCount: model.normalCount,
            abnormalCount: model.abnormalCount,
            mosaicCount: model.mosaicCount,
            inconclusiveCount: model.inconclusiveCount,
            resultStatus: model.resultStatusRawValue.flatMap(PGTResultStatus.init(rawValue:)),
            femaleChromosomeResult: model.femaleChromosomeResultRawValue.flatMap(ChromosomeResult.init(rawValue:)),
            maleChromosomeResult: model.maleChromosomeResultRawValue.flatMap(ChromosomeResult.init(rawValue:)),
            implantationTestType: model.implantationTestTypeRawValue.flatMap(ImplantationTestType.init(rawValue:)),
            implantationResult: model.implantationResultRawValue.flatMap(ImplantationResult.init(rawValue:)),
            recommendedTransferWindow: model.recommendedTransferWindow,
            memo: model.memo
        )
    }

    public static func toModel(_ entity: PGTRecord) -> PGTRecordModel {
        PGTRecordModel(
            id: entity.id,
            cycleRecordId: entity.cycleRecordId,
            testDate: entity.testDate,
            typeRawValue: entity.type.rawValue,
            normalCount: entity.normalCount,
            abnormalCount: entity.abnormalCount,
            mosaicCount: entity.mosaicCount,
            inconclusiveCount: entity.inconclusiveCount,
            resultStatusRawValue: entity.resultStatus?.rawValue,
            femaleChromosomeResultRawValue: entity.femaleChromosomeResult?.rawValue,
            maleChromosomeResultRawValue: entity.maleChromosomeResult?.rawValue,
            implantationTestTypeRawValue: entity.implantationTestType?.rawValue,
            implantationResultRawValue: entity.implantationResult?.rawValue,
            recommendedTransferWindow: entity.recommendedTransferWindow,
            memo: entity.memo
        )
    }
}
