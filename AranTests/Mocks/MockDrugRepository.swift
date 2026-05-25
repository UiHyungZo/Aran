@testable import Aran
import Foundation

final class MockDrugRepository: DrugRepositoryProtocol {
    var searchResult: [Drug] = []
    var detailResult: Drug?
    var searchKeywords: [String] = []
    var detailItemSeqs: [String] = []
    var shouldThrow: Error?

    func search(keyword: String, pageNo _: Int) async throws -> [Drug] {
        if let error = shouldThrow { throw error }
        searchKeywords.append(keyword)
        return searchResult
    }

    func detail(itemSeq: String) async throws -> Drug {
        if let error = shouldThrow { throw error }
        detailItemSeqs.append(itemSeq)
        if let detailResult { return detailResult }
        return Drug(
            itemSeq: itemSeq,
            itemName: "상세약",
            entpName: "제약사",
            efcyQesitm: nil,
            useMethodQesitm: nil,
            atpnWarnQesitm: nil,
            atpnQesitm: nil,
            intrcQesitm: nil,
            seQesitm: nil,
            depositMethodQesitm: nil,
            itemImage: nil
        )
    }
}
