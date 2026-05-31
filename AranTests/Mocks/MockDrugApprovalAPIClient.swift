import Foundation
@testable import Aran

final class MockDrugApprovalAPIClient: DrugApprovalAPIClientProtocol {
    var searchResult: DrugSearchResult?
    var infos: [DrugApprovalInfo] = []
    var error: Error?
    var capturedItemName: String?
    var capturedPageNo: Int?

    func searchDrugs(itemName: String, pageNo: Int) async throws -> DrugSearchResult {
        capturedItemName = itemName
        capturedPageNo = pageNo
        if let error { throw error }
        return searchResult ?? DrugSearchResult(drugs: [], totalCount: 0, pageNo: pageNo)
    }

    func fetchApprovalInfo(itemName: String) async throws -> [DrugApprovalInfo] {
        capturedItemName = itemName
        if let error { throw error }
        return infos
    }
}
