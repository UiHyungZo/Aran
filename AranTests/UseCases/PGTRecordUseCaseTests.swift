@testable import Aran
import XCTest

final class PGTRecordUseCaseTests: XCTestCase {
    private var repo: MockPGTRecordRepository!
    private var sut: PGTRecordUseCase!

    override func setUp() {
        super.setUp()
        repo = MockPGTRecordRepository()
        sut = PGTRecordUseCase(repository: repo)
    }

    override func tearDown() {
        sut = nil
        repo = nil
        super.tearDown()
    }

    func test_save_whenPGTCountsAreValid_thenSavesDetailedCounts() async throws {
        try await sut.save(
            cycleRecordId: UUID(),
            testDate: Date(),
            type: .pgtA,
            normalCount: 1,
            abnormalCount: 1,
            mosaicCount: 0,
            inconclusiveCount: 1,
            resultStatus: .borderline,
            femaleChromosomeResult: nil,
            maleChromosomeResult: nil,
            implantationTestType: nil,
            implantationResult: nil,
            recommendedTransferWindow: nil,
            memo: " 확인 필요 "
        )

        let saved = try XCTUnwrap(repo.savedRecords.first)
        XCTAssertEqual(saved.normalCount, 1)
        XCTAssertEqual(saved.abnormalCount, 1)
        XCTAssertEqual(saved.inconclusiveCount, 1)
        XCTAssertEqual(saved.resultStatus, .borderline)
        XCTAssertEqual(saved.memo, "확인 필요")
    }

    func test_save_whenPGTCountsAreZero_thenThrowsInvalidInput() async throws {
        do {
            try await sut.save(
                cycleRecordId: UUID(),
                testDate: Date(),
                type: .pgtM,
                normalCount: 0,
                abnormalCount: 0,
                mosaicCount: 0,
                inconclusiveCount: 0,
                resultStatus: .pending,
                femaleChromosomeResult: nil,
                maleChromosomeResult: nil,
                implantationTestType: nil,
                implantationResult: nil,
                recommendedTransferWindow: nil,
                memo: nil
            )
            XCTFail("기대한 에러가 발생하지 않았습니다.")
        } catch AppError.invalidInput {
            // expected
        } catch {
            XCTFail("예상치 못한 에러 타입: \(error)")
        }
    }

    func test_save_whenCountIsNegative_thenThrowsInvalidInput() async throws {
        do {
            try await sut.save(
                cycleRecordId: UUID(),
                testDate: Date(),
                type: .pgtA,
                normalCount: 1,
                abnormalCount: 0,
                mosaicCount: 0,
                inconclusiveCount: -1,
                resultStatus: nil,
                femaleChromosomeResult: nil,
                maleChromosomeResult: nil,
                implantationTestType: nil,
                implantationResult: nil,
                recommendedTransferWindow: nil,
                memo: nil
            )
            XCTFail("기대한 에러가 발생하지 않았습니다.")
        } catch AppError.invalidInput {
            // expected
        } catch {
            XCTFail("예상치 못한 에러 타입: \(error)")
        }
    }

    func test_save_whenChromosomeCouple_thenSavesChromosomeResultsAndClearsCounts() async throws {
        try await sut.save(
            cycleRecordId: UUID(),
            testDate: Date(),
            type: .chromosomeCouple,
            normalCount: 2,
            abnormalCount: 1,
            mosaicCount: 1,
            inconclusiveCount: 1,
            resultStatus: .abnormal,
            femaleChromosomeResult: .carrier,
            maleChromosomeResult: .normal,
            implantationTestType: .era,
            implantationResult: .receptive,
            recommendedTransferWindow: "P+5",
            memo: nil
        )

        let saved = try XCTUnwrap(repo.savedRecords.first)
        XCTAssertEqual(saved.normalCount, 0)
        XCTAssertEqual(saved.abnormalCount, 0)
        XCTAssertEqual(saved.mosaicCount, 0)
        XCTAssertEqual(saved.inconclusiveCount, 0)
        XCTAssertEqual(saved.femaleChromosomeResult, .carrier)
        XCTAssertEqual(saved.maleChromosomeResult, .normal)
        XCTAssertNil(saved.implantationTestType)
        XCTAssertNil(saved.implantationResult)
        XCTAssertNil(saved.recommendedTransferWindow)
    }

    func test_save_whenImplantation_thenSavesImplantationDetails() async throws {
        try await sut.save(
            cycleRecordId: UUID(),
            testDate: Date(),
            type: .implantation,
            normalCount: 1,
            abnormalCount: 1,
            mosaicCount: 1,
            inconclusiveCount: 1,
            resultStatus: .normal,
            femaleChromosomeResult: .abnormal,
            maleChromosomeResult: .carrier,
            implantationTestType: .era,
            implantationResult: .preReceptive,
            recommendedTransferWindow: "  P+6  ",
            memo: nil
        )

        let saved = try XCTUnwrap(repo.savedRecords.first)
        XCTAssertEqual(saved.normalCount, 0)
        XCTAssertEqual(saved.abnormalCount, 0)
        XCTAssertEqual(saved.mosaicCount, 0)
        XCTAssertEqual(saved.inconclusiveCount, 0)
        XCTAssertNil(saved.femaleChromosomeResult)
        XCTAssertNil(saved.maleChromosomeResult)
        XCTAssertEqual(saved.implantationTestType, .era)
        XCTAssertEqual(saved.implantationResult, .preReceptive)
        XCTAssertEqual(saved.recommendedTransferWindow, "P+6")
    }
}

private final class MockPGTRecordRepository: PGTRecordRepositoryProtocol {
    var fetchAllResult: [PGTRecord] = []
    var fetchCycleResult: [PGTRecord] = []
    var savedRecords: [PGTRecord] = []
    var deletedIDs: [UUID] = []
    var shouldThrow: Error?

    func fetchAll() async throws -> [PGTRecord] {
        if let error = shouldThrow { throw error }
        return fetchAllResult
    }

    func fetch(cycleRecordId: UUID) async throws -> [PGTRecord] {
        if let error = shouldThrow { throw error }
        return fetchCycleResult
    }

    func fetch(id: UUID) async throws -> PGTRecord? {
        if let error = shouldThrow { throw error }
        return fetchAllResult.first { $0.id == id }
    }

    func update(_ record: PGTRecord) async throws {
        if let error = shouldThrow { throw error }
    }

    func save(_ record: PGTRecord) async throws {
        if let error = shouldThrow { throw error }
        savedRecords.append(record)
    }

    func delete(id: UUID) async throws {
        if let error = shouldThrow { throw error }
        deletedIDs.append(id)
    }
}
