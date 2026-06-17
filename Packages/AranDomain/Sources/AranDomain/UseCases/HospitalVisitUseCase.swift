import Foundation

public protocol HospitalVisitUseCaseProtocol {
    func fetchAll() async throws -> [HospitalVisit]
    func fetch(date: Date) async throws -> [HospitalVisit]
    func save(visitDate: Date, visitTypes: [String], memo: String?) async throws
    func update(_ visit: HospitalVisit) async throws
    func delete(id: UUID) async throws
}

public final class HospitalVisitUseCase: HospitalVisitUseCaseProtocol {
    private let repository: HospitalVisitRepositoryProtocol

    public init(repository: HospitalVisitRepositoryProtocol) {
        self.repository = repository
    }

    public func fetchAll() async throws -> [HospitalVisit] {
        try await repository.fetchAll()
    }

    public func fetch(date: Date) async throws -> [HospitalVisit] {
        try await repository.fetch(date: date)
    }

    public func save(visitDate: Date, visitTypes: [String], memo: String?) async throws {
        let types = visitTypes.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard !types.isEmpty else {
            throw AppError.invalidInput("방문 유형을 1개 이상 선택해주세요.")
        }
        let visit = HospitalVisit(id: UUID(), visitDate: visitDate, visitTypes: types, memo: memo)
        try await repository.save(visit)
    }

    public func update(_ visit: HospitalVisit) async throws {
        let types = visit.visitTypes.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard !types.isEmpty else {
            throw AppError.invalidInput("방문 유형을 1개 이상 선택해주세요.")
        }
        try await repository.update(visit)
    }

    public func delete(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
