import Foundation

protocol RecentDrugSearchUseCaseProtocol {
    func fetchAll() async throws -> [String]
    func save(keyword: String) async throws
    func delete(keyword: String) async throws
    func clear() async throws
}

final class RecentDrugSearchUseCase: RecentDrugSearchUseCaseProtocol {
    private let repository: RecentDrugSearchRepositoryProtocol

    init(repository: RecentDrugSearchRepositoryProtocol) {
        self.repository = repository
    }

    func fetchAll() async throws -> [String] {
        try await repository.fetchAll().map(\.keyword)
    }

    func save(keyword: String) async throws {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKeyword.isEmpty else { return }
        try await repository.save(keyword: trimmedKeyword)
    }

    func delete(keyword: String) async throws {
        try await repository.delete(keyword: keyword)
    }

    func clear() async throws {
        try await repository.clear()
    }
}
