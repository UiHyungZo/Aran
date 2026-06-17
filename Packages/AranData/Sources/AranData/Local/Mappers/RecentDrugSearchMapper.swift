import Foundation
import AranDomain

public enum RecentDrugSearchMapper {
    public static func toDomain(_ model: RecentDrugSearchModel) -> RecentDrugSearch {
        RecentDrugSearch(
            id: model.id,
            keyword: model.keyword,
            createdAt: model.createdAt
        )
    }
}
