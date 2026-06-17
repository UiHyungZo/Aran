import Foundation

public protocol DiaryEntryRepositoryProtocol {
    func fetchAll() async throws -> [DiaryEntry]
    func fetch(date: Date) async throws -> DiaryEntry?
    func save(_ diary: DiaryEntry) async throws
    func update(_ diary: DiaryEntry) async throws
    func delete(id: UUID) async throws
}
