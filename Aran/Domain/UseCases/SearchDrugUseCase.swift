import Foundation

protocol SearchDrugUseCaseProtocol {
    func execute(keyword: String, pageNo: Int) async throws -> DrugSearchResult
    func detail(itemSeq: String) async throws -> Drug
}

final class SearchDrugUseCase: SearchDrugUseCaseProtocol {
    private let repository: DrugRepositoryProtocol

    init(repository: DrugRepositoryProtocol) {
        self.repository = repository
    }

    func execute(keyword: String, pageNo: Int = 1) async throws -> DrugSearchResult {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AppError.invalidInput("검색어를 입력해주세요.")
        }
        guard trimmed.count <= 100 else {
            throw AppError.invalidInput("검색어가 너무 깁니다.")
        }
        guard pageNo >= 1 else {
            throw AppError.invalidInput("올바르지 않은 페이지 번호입니다.")
        }
        return try await repository.search(keyword: trimmed, pageNo: pageNo)
    }

    func detail(itemSeq: String) async throws -> Drug {
        guard !itemSeq.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AppError.invalidInput("약품 코드가 올바르지 않습니다.")
        }
        return try await repository.detail(itemSeq: itemSeq)
    }
}
