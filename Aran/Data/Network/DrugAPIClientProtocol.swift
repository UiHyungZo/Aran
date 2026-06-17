import Foundation
import AranDomain

protocol DrugAPIClientProtocol {
    func searchDrugs(keyword: String, pageNo: Int) async throws -> DrugSearchResult
}
