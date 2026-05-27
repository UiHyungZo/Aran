import Foundation

final class MedicationLogUseCase {
    private let repository: MedicationLogRepositoryProtocol

    init(repository: MedicationLogRepositoryProtocol) {
        self.repository = repository
    }

    func fetchAll() async throws -> [MedicationLog] {
        try await repository.fetchAll()
    }

    func fetch(date: Date) async throws -> [MedicationLog] {
        try await repository.fetch(date: date)
    }

    func fetch(medicationId: UUID, date: Date) async throws -> MedicationLog? {
        try await repository.fetch(medicationId: medicationId, date: date)
    }

    func toggle(medicationId: UUID, date: Date) async throws {
        if var existing = try await repository.fetch(medicationId: medicationId, date: date) {
            existing.isTaken.toggle()
            try await repository.upsert(existing)
        } else {
            let log = MedicationLog(
                id: UUID(),
                medicationId: medicationId,
                logDate: Calendar.current.startOfDay(for: date),
                isTaken: true
            )
            try await repository.upsert(log)
        }
    }
}
