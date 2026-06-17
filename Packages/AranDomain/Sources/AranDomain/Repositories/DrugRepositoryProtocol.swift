import Foundation

public protocol DrugRepositoryProtocol {
    func search(keyword: String, pageNo: Int) async throws -> DrugSearchResult
    func enrich(_ drug: Drug) async throws -> Drug
}
