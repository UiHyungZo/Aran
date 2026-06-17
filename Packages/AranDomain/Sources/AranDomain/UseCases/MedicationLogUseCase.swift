import Foundation

public protocol MedicationLogUseCaseProtocol {
    func fetchAll() async throws -> [MedicationLog]
    func fetch(date: Date) async throws -> [MedicationLog]
    func fetch(medicationId: UUID, date: Date) async throws -> MedicationLog?
    func toggle(medicationId: UUID, date: Date, timeSlotID: UUID) async throws
}

public final class MedicationLogUseCase: MedicationLogUseCaseProtocol {
    private let repository: MedicationLogRepositoryProtocol

    public init(repository: MedicationLogRepositoryProtocol) {
        self.repository = repository
    }

    public func fetchAll() async throws -> [MedicationLog] {
        try await repository.fetchAll()
    }

    public func fetch(date: Date) async throws -> [MedicationLog] {
        try await repository.fetch(date: date)
    }

    public func fetch(medicationId: UUID, date: Date) async throws -> MedicationLog? {
        try await repository.fetch(medicationId: medicationId, date: date)
    }

    public func toggle(medicationId: UUID, date: Date, timeSlotID: UUID) async throws {
        if var existing = try await repository.fetch(medicationId: medicationId, date: date, timeSlotID: timeSlotID) {
            existing.isTaken.toggle()
            try await repository.upsert(existing)
        } else {
            let log = MedicationLog(
                id: UUID(),
                medicationId: medicationId,
                logDate: Calendar.current.startOfDay(for: date),
                isTaken: true,
                timeSlotID: timeSlotID
            )
            try await repository.upsert(log)
        }
    }
}
