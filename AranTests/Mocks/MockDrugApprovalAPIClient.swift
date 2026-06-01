import Foundation
@testable import Aran

final class MockDrugApprovalAPIClient: DrugApprovalAPIClientProtocol {
    var searchResult: DrugSearchResult?
    var detailDrug: Drug?
    var error: Error?
    var capturedItemName: String?
    var capturedItemSeq: String?
    var capturedPageNo: Int?

    func searchDrugs(itemName: String, pageNo: Int) async throws -> DrugSearchResult {
        capturedItemName = itemName
        capturedPageNo = pageNo
        if let error { throw error }
        return searchResult ?? DrugSearchResult(drugs: [], totalCount: 0, pageNo: pageNo)
    }

    func fetchDetail(itemSeq: String) async throws -> Drug? {
        capturedItemSeq = itemSeq
        if let error { throw error }
        return detailDrug
    }
}
