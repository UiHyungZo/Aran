@testable import Aran
import Foundation

final class MockDiaryEntryUseCase: DiaryEntryUseCaseProtocol {
    var stubbedAll: [DiaryEntry] = []
    var stubbedEntry: DiaryEntry?
    var shouldThrow: Error?

    func fetchAll() async throws -> [DiaryEntry] {
        if let error = shouldThrow { throw error }
        return stubbedAll
    }

    func fetch(date: Date) async throws -> DiaryEntry? {
        if let error = shouldThrow { throw error }
        return stubbedEntry
    }

    func save(date: Date, emoji: String?, content: String) async throws {
        if let error = shouldThrow { throw error }
    }
}
