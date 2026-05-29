import Foundation

protocol FavoriteDrugUseCaseProtocol {
    func fetchAll() async throws -> [FavoriteDrug]
    func isFavorite(itemSeq: String) async throws -> Bool
    func toggle(drug: Drug) async throws
    func delete(itemSeq: String) async throws
}

final class FavoriteDrugUseCase: FavoriteDrugUseCaseProtocol {
    private let repository: FavoriteDrugRepositoryProtocol

    init(repository: FavoriteDrugRepositoryProtocol) {
        self.repository = repository
    }

    func fetchAll() async throws -> [FavoriteDrug] {
        try await repository.fetchAll()
    }

    func isFavorite(itemSeq: String) async throws -> Bool {
        try await repository.exists(itemSeq: itemSeq)
    }

    func toggle(drug: Drug) async throws {
        if try await repository.exists(itemSeq: drug.itemSeq) {
            try await repository.delete(itemSeq: drug.itemSeq)
        } else {
            try await repository.save(FavoriteDrug(drug: drug))
        }
    }

    func delete(itemSeq: String) async throws {
        try await repository.delete(itemSeq: itemSeq)
    }
}
