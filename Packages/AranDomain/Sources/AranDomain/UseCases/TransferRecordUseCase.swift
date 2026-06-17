import Foundation

public protocol TransferRecordUseCaseProtocol {
    func fetchAll() async throws -> [TransferRecord]
    func fetch(id: UUID) async throws -> TransferRecord?
    func fetch(for date: Date) async throws -> [TransferRecord]
    func save(_ record: TransferRecord) async throws
    func update(_ record: TransferRecord) async throws
    func delete(id: UUID) async throws
}

public final class TransferRecordUseCase: TransferRecordUseCaseProtocol {
    private let repository: TransferRecordRepositoryProtocol

    public init(repository: TransferRecordRepositoryProtocol) {
        self.repository = repository
    }

    public func fetchAll() async throws -> [TransferRecord] {
        try await repository.fetchAll()
    }

    public func fetch(id: UUID) async throws -> TransferRecord? {
        try await repository.fetch(id: id)
    }

    public func fetch(for date: Date) async throws -> [TransferRecord] {
        try await repository.fetch(for: date)
    }

    public func save(_ record: TransferRecord) async throws {
        try await repository.save(record)
    }

    public func update(_ record: TransferRecord) async throws {
        try await repository.update(record)
    }

    public func delete(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
