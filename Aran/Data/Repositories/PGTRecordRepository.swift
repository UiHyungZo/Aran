import Foundation
import SwiftData
import AranDomain

@MainActor
final class PGTRecordRepository: PGTRecordRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() async throws -> [PGTRecord] {
        let descriptor = FetchDescriptor<PGTRecordModel>(
            sortBy: [SortDescriptor(\.testDate, order: .reverse)]
        )
        return try context.fetch(descriptor).map { PGTRecordMapper.toDomain($0) }
    }

    func fetch(cycleRecordId: UUID) async throws -> [PGTRecord] {
        let descriptor = FetchDescriptor<PGTRecordModel>(
            predicate: #Predicate { $0.cycleRecordId == cycleRecordId },
            sortBy: [SortDescriptor(\.testDate)]
        )
        return try context.fetch(descriptor).map { PGTRecordMapper.toDomain($0) }
    }

    func fetch(id: UUID) async throws -> PGTRecord? {
        let descriptor = FetchDescriptor<PGTRecordModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first.map { PGTRecordMapper.toDomain($0) }
    }

    func save(_ record: PGTRecord) async throws {
        let model = PGTRecordMapper.toModel(record)
        context.insert(model)
        try context.save()
    }

    func update(_ record: PGTRecord) async throws {
        let id = record.id
        let descriptor = FetchDescriptor<PGTRecordModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try context.fetch(descriptor).first else { return }
        model.testDate = record.testDate
        model.typeRawValue = record.type.rawValue
        model.normalCount = record.normalCount
        model.abnormalCount = record.abnormalCount
        model.mosaicCount = record.mosaicCount
        model.inconclusiveCount = record.inconclusiveCount
        model.resultStatusRawValue = record.resultStatus?.rawValue
        model.femaleChromosomeResultRawValue = record.femaleChromosomeResult?.rawValue
        model.maleChromosomeResultRawValue = record.maleChromosomeResult?.rawValue
        model.implantationTestTypeRawValue = record.implantationTestType?.rawValue
        model.implantationResultRawValue = record.implantationResult?.rawValue
        model.recommendedTransferWindow = record.recommendedTransferWindow
        model.memo = record.memo
        try context.save()
    }

    func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<PGTRecordModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try context.fetch(descriptor).first {
            context.delete(model)
            try context.save()
        }
    }
}
