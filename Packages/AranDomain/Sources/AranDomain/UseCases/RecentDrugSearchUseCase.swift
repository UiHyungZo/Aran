import Foundation

public protocol RecentDrugSearchUseCaseProtocol {
    func fetchAll() async throws -> [String]
    func save(keyword: String) async throws
    func delete(keyword: String) async throws
    func clear() async throws
}

public final class RecentDrugSearchUseCase: RecentDrugSearchUseCaseProtocol {
    private let repository: RecentDrugSearchRepositoryProtocol

    public init(repository: RecentDrugSearchRepositoryProtocol) {
        self.repository = repository
    }

    public func fetchAll() async throws -> [String] {
        try await repository.fetchAll().map(\.keyword)
    }

    public func save(keyword: String) async throws {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKeyword.isEmpty else { return }
        try await repository.save(keyword: trimmedKeyword)
    }

    public func delete(keyword: String) async throws {
        try await repository.delete(keyword: keyword)
    }

    public func clear() async throws {
        try await repository.clear()
    }
}
