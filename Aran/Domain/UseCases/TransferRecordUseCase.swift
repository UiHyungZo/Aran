import Foundation

protocol TransferRecordUseCaseProtocol {
    func fetchAll() async throws -> [TransferRecord]
    func fetch(id: UUID) async throws -> TransferRecord?
    func fetch(for date: Date) async throws -> [TransferRecord]
    func save(_ record: TransferRecord) async throws
    func update(_ record: TransferRecord) async throws
    func delete(id: UUID) async throws
}

final class TransferRecordUseCase: TransferRecordUseCaseProtocol {
    private let repository: TransferRecordRepositoryProtocol

    init(repository: TransferRecordRepositoryProtocol) {
        self.repository = repository
    }

    func fetchAll() async throws -> [TransferRecord] {
        try await repository.fetchAll()
    }

    func fetch(id: UUID) async throws -> TransferRecord? {
        try await repository.fetch(id: id)
    }

    func fetch(for date: Date) async throws -> [TransferRecord] {
        try await repository.fetch(for: date)
    }

    func save(_ record: TransferRecord) async throws {
        try await repository.save(record)
    }

    func update(_ record: TransferRecord) async throws {
        try await repository.update(record)
    }

    func delete(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
