import Foundation

public struct DrugSearchResult {
    public let drugs: [Drug]
    public let totalCount: Int
    public let pageNo: Int

    public init(drugs: [Drug], totalCount: Int, pageNo: Int) {
        self.drugs = drugs
        self.totalCount = totalCount
        self.pageNo = pageNo
    }
}
