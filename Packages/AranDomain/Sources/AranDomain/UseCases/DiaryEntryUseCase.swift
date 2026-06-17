import Foundation

public protocol DiaryEntryUseCaseProtocol {
    func fetchAll() async throws -> [DiaryEntry]
    func fetch(date: Date) async throws -> DiaryEntry?
    func save(date: Date, emoji: String?, content: String) async throws
    func delete(id: UUID) async throws
}

public final class DiaryEntryUseCase: DiaryEntryUseCaseProtocol {
    private let repository: DiaryEntryRepositoryProtocol

    public init(repository: DiaryEntryRepositoryProtocol) {
        self.repository = repository
    }

    public func fetchAll() async throws -> [DiaryEntry] {
        try await repository.fetchAll()
    }

    public func fetch(date: Date) async throws -> DiaryEntry? {
        try await repository.fetch(date: date)
    }

    public func delete(id: UUID) async throws {
        try await repository.delete(id: id)
    }

    public func save(date: Date, emoji: String?, content: String) async throws {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AppError.invalidInput("일기 내용을 입력해주세요.")
        }
        guard trimmed.count <= 500 else {
            throw AppError.invalidInput("일기는 500자 이하로 입력해주세요.")
        }
        if var existing = try await repository.fetch(date: date) {
            existing.emoji = emoji
            existing.content = trimmed
            try await repository.update(existing)
        } else {
            try await repository.save(DiaryEntry(id: UUID(), date: date, emoji: emoji, content: trimmed))
        }
    }
}
