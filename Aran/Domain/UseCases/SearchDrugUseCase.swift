import Foundation

final class SearchDrugUseCase {
    private let repository: DrugRepositoryProtocol

    init(repository: DrugRepositoryProtocol) {
        self.repository = repository
    }

    func execute(keyword: String, pageNo: Int = 1) async throws -> [Drug] {
        guard !keyword.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AppError.invalidInput("검색어를 입력해주세요.")
        }
        return try await repository.search(keyword: keyword, pageNo: pageNo)
    }

    func detail(itemSeq: String) async throws -> Drug {
        return try await repository.detail(itemSeq: itemSeq)
    }
}
