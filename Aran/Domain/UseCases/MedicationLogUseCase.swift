import Foundation

protocol MedicationLogUseCaseProtocol {
    func fetchAll() async throws -> [MedicationLog]
    func fetch(date: Date) async throws -> [MedicationLog]
    func fetch(medicationId: UUID, date: Date) async throws -> MedicationLog?
    func toggle(medicationId: UUID, date: Date, timeIndex: Int) async throws
}

final class MedicationLogUseCase: MedicationLogUseCaseProtocol {
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

    func toggle(medicationId: UUID, date: Date, timeIndex: Int) async throws {
        if var existing = try await repository.fetch(medicationId: medicationId, date: date, timeIndex: timeIndex) {
            existing.isTaken.toggle()
            try await repository.upsert(existing)
        } else {
            let log = MedicationLog(
                id: UUID(),
                medicationId: medicationId,
                logDate: Calendar.current.startOfDay(for: date),
                isTaken: true,
                timeIndex: timeIndex
            )
            try await repository.upsert(log)
        }
    }
}
