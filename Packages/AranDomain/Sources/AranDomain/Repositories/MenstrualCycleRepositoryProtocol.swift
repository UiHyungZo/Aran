import Foundation

public protocol MenstrualCycleRepositoryProtocol {
    func fetchAll() async throws -> [MenstrualCycle]
    func fetch(date: Date) async throws -> MenstrualCycle?
    func save(_ cycle: MenstrualCycle) async throws
    func update(_ cycle: MenstrualCycle) async throws
    func delete(id: UUID) async throws
}
