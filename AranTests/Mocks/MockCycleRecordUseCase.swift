@testable import Aran
import Foundation
import AranDomain

final class MockCycleRecordUseCase: CycleRecordUseCaseProtocol {
    var stubbedAll: [CycleRecord] = []
    var stubbedRecord: CycleRecord?
    var shouldThrow: Error?
    var addedEvents: [(event: DayEvent, date: Date, cycleNumber: Int)] = []
    var removedTransferIDs: [UUID] = []

    func fetchAll() async throws -> [CycleRecord] {
        if let error = shouldThrow { throw error }
        return stubbedAll
    }

    func fetch(date: Date) async throws -> CycleRecord? {
        if let error = shouldThrow { throw error }
        return stubbedRecord
    }

    func save(cycleNumber: Int, startDate: Date, retrievalCount: Int, fertilizedCount: Int, frozenCount: Int, embryoRecords: [EmbryoRecord]) async throws {
        if let error = shouldThrow { throw error }
    }

    func update(cycleNumber: Int, startDate: Date, retrievalCount: Int, fertilizedCount: Int, frozenCount: Int, embryoRecords: [EmbryoRecord]) async throws {
        if let error = shouldThrow { throw error }
    }

    func delete(id: UUID) async throws {
        if let error = shouldThrow { throw error }
    }

    func addEvent(_ event: DayEvent, to date: Date, cycleNumber: Int) async throws {
        if let error = shouldThrow { throw error }
        addedEvents.append((event: event, date: date, cycleNumber: cycleNumber))
    }

    func removeTransferEvent(transferID: UUID) async throws {
        if let error = shouldThrow { throw error }
        removedTransferIDs.append(transferID)
    }

    func saveDiary(emoji: String?, text: String, for date: Date) async throws {
        if let error = shouldThrow { throw error }
    }

    func clearDiary(for date: Date) async throws {
        if let error = shouldThrow { throw error }
    }

    func estimateOvulation(from periodStart: Date, cycleLength: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: cycleLength - 14, to: periodStart) ?? periodStart
    }
}
