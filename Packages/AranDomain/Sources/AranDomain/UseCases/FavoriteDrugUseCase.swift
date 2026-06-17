import Foundation

public protocol FavoriteDrugUseCaseProtocol {
    func fetchAll() async throws -> [FavoriteDrug]
    func isFavorite(itemSeq: String) async throws -> Bool
    func toggle(drug: Drug) async throws
    func updateDetailIfFavorited(drug: Drug) async throws
    func delete(itemSeq: String) async throws
}

public final class FavoriteDrugUseCase: FavoriteDrugUseCaseProtocol {
    private let repository: FavoriteDrugRepositoryProtocol

    public init(repository: FavoriteDrugRepositoryProtocol) {
        self.repository = repository
    }

    public func fetchAll() async throws -> [FavoriteDrug] {
        try await repository.fetchAll()
    }

    public func isFavorite(itemSeq: String) async throws -> Bool {
        try await repository.exists(itemSeq: itemSeq)
    }

    public func toggle(drug: Drug) async throws {
        if try await repository.exists(itemSeq: drug.itemSeq) {
            try await repository.delete(itemSeq: drug.itemSeq)
        } else {
            try await repository.save(FavoriteDrug(drug: drug))
        }
    }

    public func updateDetailIfFavorited(drug: Drug) async throws {
        guard try await repository.exists(itemSeq: drug.itemSeq) else { return }
        try await repository.save(FavoriteDrug(drug: drug))
    }

    public func delete(itemSeq: String) async throws {
        try await repository.delete(itemSeq: itemSeq)
    }
}
