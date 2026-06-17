@testable import Aran
import Foundation
import AranDomain

final class MockDiaryEntryRepository: DiaryEntryRepositoryProtocol {
    var entries: [DiaryEntry] = []

    func fetchAll() async throws -> [DiaryEntry] {
        entries
    }

    func fetch(date: Date) async throws -> DiaryEntry? {
        let day = Calendar.current.startOfDay(for: date)
        return entries.first { Calendar.current.isDate($0.date, inSameDayAs: day) }
    }

    func save(_ diary: DiaryEntry) async throws {
        entries.append(diary)
    }

    func update(_ diary: DiaryEntry) async throws {
        if let index = entries.firstIndex(where: { $0.id == diary.id }) {
            entries[index] = diary
        }
    }

    func delete(id: UUID) async throws {
        entries.removeAll { $0.id == id }
    }
}
