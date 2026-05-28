import Foundation

protocol DrugAPIClientProtocol {
    func searchDrugs(keyword: String, pageNo: Int) async throws -> DrugSearchResult
    func fetchDrugDetail(itemSeq: String) async throws -> Drug
}
