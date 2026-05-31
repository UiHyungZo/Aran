import Foundation

protocol DrugRepositoryProtocol {
    func search(keyword: String, pageNo: Int) async throws -> DrugSearchResult
}
