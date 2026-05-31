import Foundation

protocol SearchDrugUseCaseProtocol {
    func execute(keyword: String, pageNo: Int) async throws -> DrugSearchResult
    func enrich(_ drug: Drug) async throws -> Drug
}

final class SearchDrugUseCase: SearchDrugUseCaseProtocol {
    private let repository: DrugRepositoryProtocol

    init(repository: DrugRepositoryProtocol) {
        self.repository = repository
    }

    func execute(keyword: String, pageNo: Int = 1) async throws -> DrugSearchResult {
        guard !keyword.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AppError.invalidInput("검색어를 입력해주세요.")
        }
        return try await repository.search(keyword: keyword, pageNo: pageNo)
    }

    func enrich(_ drug: Drug) async throws -> Drug {
        try await repository.enrich(drug)
    }
}
