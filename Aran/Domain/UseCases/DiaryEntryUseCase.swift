import Foundation

final class DiaryEntryUseCase {
    private let repository: DiaryEntryRepositoryProtocol

    init(repository: DiaryEntryRepositoryProtocol) {
        self.repository = repository
    }

    func fetchAll() async throws -> [DiaryEntry] {
        try await repository.fetchAll()
    }

    func fetch(date: Date) async throws -> DiaryEntry? {
        try await repository.fetch(date: date)
    }

    func save(date: Date, emoji: String?, content: String) async throws {
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
            try await repository.save(DiaryEntry(date: date, emoji: emoji, content: trimmed))
        }
    }
}
