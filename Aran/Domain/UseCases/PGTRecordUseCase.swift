import Foundation

final class PGTRecordUseCase {
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

    func save(
        cycleRecordId: UUID,
        testDate: Date,
        type: PGTType,
        normalCount: Int,
        abnormalCount: Int,
        mosaicCount: Int,
        memo: String?
    ) async throws {
        guard normalCount >= 0, abnormalCount >= 0, mosaicCount >= 0 else {
            throw AppError.invalidInput("개수는 0 이상이어야 합니다.")
        }

        if type.showsEmbryoCounts {
            let total = normalCount + abnormalCount + mosaicCount
            guard total > 0 else {
                throw AppError.invalidInput("최소 1개 이상의 배아 결과를 입력해주세요.")
            }
        }

        let record = PGTRecord(
            id: UUID(),
            cycleRecordId: cycleRecordId,
            testDate: testDate,
            type: type,
            normalCount: type.showsEmbryoCounts ? normalCount : 0,
            abnormalCount: type.showsEmbryoCounts ? abnormalCount : 0,
            mosaicCount: type.showsEmbryoCounts ? mosaicCount : 0,
            memo: memo?.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        try await repository.save(record)
    }

    func delete(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
