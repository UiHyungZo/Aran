import XCTest
import AranDomain

final class TransferRecordUseCaseTests: XCTestCase {
    private var repo: MockTransferRecordRepository!
    private var sut: TransferRecordUseCase!

    override func setUp() {
        super.setUp()
        repo = MockTransferRecordRepository()
        sut = TransferRecordUseCase(repository: repo)
    }

    override func tearDown() {
        sut = nil
        repo = nil
        super.tearDown()
    }

    func test_fetchAll_whenRepositoryReturnsRecords_thenReturnsAll() async throws {
        // given
        let expected = [makeRecord(), makeRecord()]
        repo.fetchAllResult = expected

        // when
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.map(\.id), expected.map(\.id))
    }

    func test_fetchByID_whenRecordExists_thenReturnsRecord() async throws {
        // given
        let record = makeRecord()
        repo.fetchByIDResult = record

        // when
        let result = try await sut.fetch(id: record.id)

        // then
        XCTAssertEqual(result?.id, record.id)
    }

    func test_fetchByID_whenRecordNotFound_thenReturnsNil() async throws {
        // given
        repo.fetchByIDResult = nil

        // when
        let result = try await sut.fetch(id: UUID())

        // then
        XCTAssertNil(result)
    }

    func test_fetchByDate_whenRecordsExistForDate_thenReturnsMatching() async throws {
        // given
        let record = makeRecord()
        repo.fetchByDateResult = [record]

        // when
        let result = try await sut.fetch(for: record.date)

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, record.id)
    }

    func test_save_whenRecordIsValid_thenDelegatesToRepository() async throws {
        // given
        let record = makeRecord(grade: "4AA", count: 2)

        // when
        try await sut.save(record)

        // then
        XCTAssertEqual(repo.savedRecords.count, 1)
        XCTAssertEqual(repo.savedRecords.first?.embryoGrade, "4AA")
        XCTAssertEqual(repo.savedRecords.first?.embryoCount, 2)
    }

    func test_update_whenRecordIsValid_thenDelegatesToRepository() async throws {
        // given
        let record = makeRecord(result: .pregnant)

        // when
        try await sut.update(record)

        // then
        XCTAssertEqual(repo.updatedRecords.count, 1)
        XCTAssertEqual(repo.updatedRecords.first?.result, .pregnant)
    }

    func test_delete_whenIDIsValid_thenDelegatesToRepository() async throws {
        // given
        let id = UUID()

        // when
        try await sut.delete(id: id)

        // then
        XCTAssertEqual(repo.deletedIDs, [id])
    }

    func test_save_whenRepositoryThrows_thenPropagatesError() async {
        // given
        repo.shouldThrow = AppError.invalidInput("테스트 에러")

        // when / then
        do {
            try await sut.save(makeRecord())
            XCTFail("에러가 전파되어야 합니다.")
        } catch AppError.invalidInput {
            // expected
        } catch {
            XCTFail("예상치 못한 에러 타입: \(error)")
        }
    }
}

private extension TransferRecordUseCaseTests {
    func makeRecord(
        grade: String = "3BB",
        count: Int = 1,
        transferType: TransferType = .frozen,
        result: TransferResult = .waiting
    ) -> TransferRecord {
        TransferRecord(
            id: UUID(),
            cycleNumber: 1,
            date: Date(),
            embryoGrade: grade,
            embryoCount: count,
            transferType: transferType,
            result: result,
            memo: nil
        )
    }
}
