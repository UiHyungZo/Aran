import Foundation
import AranDomain

enum HospitalVisitMapper {
    static func toDomain(_ model: HospitalVisitModel) -> HospitalVisit {
        HospitalVisit(
            id: model.id,
            visitDate: model.visitDate,
            visitTypes: model.visitTypes,
            memo: model.memo
        )
    }

    static func toModel(_ entity: HospitalVisit) -> HospitalVisitModel {
        HospitalVisitModel(
            id: entity.id,
            visitDate: entity.visitDate,
            visitTypes: entity.visitTypes,
            memo: entity.memo
        )
    }
}
