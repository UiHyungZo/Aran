import Foundation
import AranDomain

public protocol DrugAPIClientProtocol {
    func searchDrugs(keyword: String, pageNo: Int) async throws -> DrugSearchResult
}
