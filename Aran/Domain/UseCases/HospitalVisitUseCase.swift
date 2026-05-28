import Foundation

protocol HospitalVisitUseCaseProtocol {
    func fetchAll() async throws -> [HospitalVisit]
    func fetch(date: Date) async throws -> [HospitalVisit]
    func save(visitDate: Date, visitTypes: [String], memo: String?) async throws
    func update(_ visit: HospitalVisit) async throws
    func delete(id: UUID) async throws
}

final class HospitalVisitUseCase: HospitalVisitUseCaseProtocol {
    private let repository: HospitalVisitRepositoryProtocol

    init(repository: HospitalVisitRepositoryProtocol) {
        self.repository = repository
    }

    func fetchAll() async throws -> [HospitalVisit] {
        try await repository.fetchAll()
    }

    func fetch(date: Date) async throws -> [HospitalVisit] {
        try await repository.fetch(date: date)
    }

    func save(visitDate: Date, visitTypes: [String], memo: String?) async throws {
        let types = visitTypes.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard !types.isEmpty else {
            throw AppError.invalidInput("방문 유형을 1개 이상 선택해주세요.")
        }
        let visit = HospitalVisit(id: UUID(), visitDate: visitDate, visitTypes: types, memo: memo)
        try await repository.save(visit)
    }

    func update(_ visit: HospitalVisit) async throws {
        let types = visit.visitTypes.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard !types.isEmpty else {
            throw AppError.invalidInput("방문 유형을 1개 이상 선택해주세요.")
        }
        try await repository.update(visit)
    }

    func delete(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
