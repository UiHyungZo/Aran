import Foundation

protocol PGTRecordUseCaseProtocol {
    func fetchAll() async throws -> [PGTRecord]
    func fetch(cycleRecordId: UUID) async throws -> [PGTRecord]
    func fetch(id: UUID) async throws -> PGTRecord?
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
    ) async throws
    func update(_ record: PGTRecord) async throws
    func delete(id: UUID) async throws
}

final class PGTRecordUseCase: PGTRecordUseCaseProtocol {
    private let repository: PGTRecordRepositoryProtocol

    init(repository: PGTRecordRepositoryProtocol) {
        self.repository = repository
    }

    func fetchAll() async throws -> [PGTRecord] {
        try await repository.fetchAll()
    }

    func fetch(cycleRecordId: UUID) async throws -> [PGTRecord] {
        try await repository.fetch(cycleRecordId: cycleRecordId)
    }

    func fetch(id: UUID) async throws -> PGTRecord? {
        try await repository.fetch(id: id)
    }

    func save(
        cycleRecordId: UUID,
        testDate: Date,
        type: PGTType,
        normalCount: Int,
        abnormalCount: Int,
        mosaicCount: Int,
        inconclusiveCount: Int = 0,
        resultStatus: PGTResultStatus? = nil,
        femaleChromosomeResult: ChromosomeResult? = nil,
        maleChromosomeResult: ChromosomeResult? = nil,
        implantationTestType: ImplantationTestType? = nil,
        implantationResult: ImplantationResult? = nil,
        recommendedTransferWindow: String? = nil,
        memo: String?
    ) async throws {
        guard normalCount >= 0, abnormalCount >= 0, mosaicCount >= 0, inconclusiveCount >= 0 else {
            throw AppError.invalidInput("개수는 0 이상이어야 합니다.")
        }

        if type.showsEmbryoCounts {
            let total = normalCount + abnormalCount + mosaicCount + inconclusiveCount
            guard total > 0 else {
                throw AppError.invalidInput("최소 1개 이상의 배아 결과를 입력해주세요.")
            }
        }

        let trimmedTransferWindow = recommendedTransferWindow?.trimmingCharacters(in: .whitespacesAndNewlines)

        let record = PGTRecord(
            id: UUID(),
            cycleRecordId: cycleRecordId,
            testDate: testDate,
            type: type,
            normalCount: type.showsEmbryoCounts ? normalCount : 0,
            abnormalCount: type.showsEmbryoCounts ? abnormalCount : 0,
            mosaicCount: type.showsEmbryoCounts ? mosaicCount : 0,
            inconclusiveCount: type.showsEmbryoCounts ? inconclusiveCount : 0,
            resultStatus: resultStatus,
            femaleChromosomeResult: type == .chromosomeCouple ? femaleChromosomeResult : nil,
            maleChromosomeResult: type == .chromosomeCouple ? maleChromosomeResult : nil,
            implantationTestType: type == .implantation ? implantationTestType : nil,
            implantationResult: type == .implantation ? implantationResult : nil,
            recommendedTransferWindow: type == .implantation && trimmedTransferWindow?.isEmpty == false ? trimmedTransferWindow : nil,
            memo: memo?.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        try await repository.save(record)
    }

    func update(_ record: PGTRecord) async throws {
        try await repository.update(record)
    }

    func delete(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
