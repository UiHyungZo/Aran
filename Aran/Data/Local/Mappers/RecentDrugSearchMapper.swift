import Foundation

enum RecentDrugSearchMapper {
    static func toDomain(_ model: RecentDrugSearchModel) -> RecentDrugSearch {
        RecentDrugSearch(
            id: model.id,
            keyword: model.keyword,
            createdAt: model.createdAt
        )
    }
}
