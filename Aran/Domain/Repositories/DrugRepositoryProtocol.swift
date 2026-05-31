import Foundation

protocol DrugRepositoryProtocol {
    func search(keyword: String, pageNo: Int) async throws -> DrugSearchResult
    func enrich(_ drug: Drug) async throws -> Drug
}
