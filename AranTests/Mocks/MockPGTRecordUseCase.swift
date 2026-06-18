import Foundation
import AranDomain

final class MockPGTRecordUseCase: PGTRecordUseCaseProtocol {
    var stubbedAll: [PGTRecord] = []
    var stubbedByCycle: [PGTRecord] = []
    var deletedIDs: [UUID] = []
    var shouldThrow: Error?

    func fetchAll() async throws -> [PGTRecord] {
        if let error = shouldThrow { throw error }
        return stubbedAll
    }

    func fetch(cycleRecordId: UUID) async throws -> [PGTRecord] {
        if let error = shouldThrow { throw error }
        return stubbedByCycle
    }

    func fetch(id: UUID) async throws -> PGTRecord? {
        if let error = shouldThrow { throw error }
        return stubbedAll.first { $0.id == id }
    }

    func update(_ record: PGTRecord) async throws {
        if let error = shouldThrow { throw error }
    }

    func save(
        cycleRecordId: UUID,
        testDate: Date,
        type: PGTType,
        normalCount: Int,
        abnormalCount: Int,
        mosaicCount: Int,
        inconclusiveCount: Int,
        resultStatus: PGTResultStatus?,
        femaleChromosomeResult: ChromosomeResult?,
        maleChromosomeResult: ChromosomeResult?,
        implantationTestType: ImplantationTestType?,
        implantationResult: ImplantationResult?,
        recommendedTransferWindow: String?,
        memo: String?
    ) async throws {
        if let error = shouldThrow { throw error }
    }

    func delete(id: UUID) async throws {
        if let error = shouldThrow { throw error }
        deletedIDs.append(id)
    }
}
