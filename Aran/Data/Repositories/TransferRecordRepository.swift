import Foundation
import SwiftData
import AranDomain

@MainActor
final class TransferRecordRepository: TransferRecordRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetch(id: UUID) async throws -> TransferRecord? {
        let descriptor = FetchDescriptor<TransferRecordModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first.map { TransferRecordMapper.toDomain($0) }
    }

    func fetch(for date: Date) async throws -> [TransferRecord] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return [] }
        let descriptor = FetchDescriptor<TransferRecordModel>(
            predicate: #Predicate { $0.date >= start && $0.date < end },
            sortBy: [SortDescriptor(\.date)]
        )
        return try context.fetch(descriptor).map { TransferRecordMapper.toDomain($0) }
    }

    func fetchAll() async throws -> [TransferRecord] {
        let descriptor = FetchDescriptor<TransferRecordModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor).map { TransferRecordMapper.toDomain($0) }
    }

    func save(_ record: TransferRecord) async throws {
        let model = TransferRecordMapper.toModel(record)
        context.insert(model)
        try context.save()
    }

    func update(_ record: TransferRecord) async throws {
        let id = record.id
        let descriptor = FetchDescriptor<TransferRecordModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try context.fetch(descriptor).first else { return }
        model.cycleNumber = record.cycleNumber
        model.embryoGrade = record.embryoGrade
        model.embryoCount = record.embryoCount
        model.transferTypeRawValue = record.transferType.rawValue
        model.resultRawValue = record.result.rawValue
        model.memo = record.memo
        try context.save()
    }

    func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<TransferRecordModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try context.fetch(descriptor).first {
            context.delete(model)
            try context.save()
        }
    }
}
