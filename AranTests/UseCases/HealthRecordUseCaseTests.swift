@testable import Aran
import XCTest

final class HealthRecordUseCaseTests: XCTestCase {
    private var repo: MockHealthRecordRepository!
    private var sut: HealthRecordUseCase!

    override func setUp() {
        super.setUp()
        repo = MockHealthRecordRepository()
        sut = HealthRecordUseCase(repository: repo)
    }

    override func tearDown() {
        sut = nil
        repo = nil
        super.tearDown()
    }

    // MARK: - fetchAll

    func testFetchAll_returnsAllRecords() async throws {
        // given
        let expected = [makeRecord(item: .fsh, value: 5.2), makeRecord(item: .amh, value: 1.1)]
        repo.fetchAllResult = expected

        // when
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.map(\.testItem), expected.map(\.testItem))
    }

    // MARK: - fetch(item:)

    func testFetch_sortsByDateDescending() async throws {
        // given
        let older = makeRecord(item: .fsh, value: 4.0, date: Date(timeIntervalSinceNow: -86400))
        let newer = makeRecord(item: .fsh, value: 6.0, date: Date())
        repo.fetchItemResult = [older, newer]

        // when
        let result = try await sut.fetch(item: .fsh)

        // then
        XCTAssertEqual(result.first?.value, newer.value)
        XCTAssertEqual(result.last?.value, older.value)
    }

    // MARK: - save(item:value:date:note:)

    func testSave_withValidValue_savesToRepository() async throws {
        // given / when
        try await sut.save(item: .fsh, value: 5.2, date: Date(), note: nil)

        // then
        XCTAssertEqual(repo.savedRecords.count, 1)
        XCTAssertEqual(repo.savedRecords.first?.value, 5.2)
    }

    func testSave_whenValueIsZero_throwsInvalidInput() async throws {
        // given / when / then
        do {
            try await sut.save(item: .fsh, value: 0, date: Date(), note: nil)
            XCTFail("기대한 에러가 발생하지 않았습니다.")
        } catch AppError.invalidInput {
            // 정상
        } catch {
            XCTFail("예상치 못한 에러 타입: \(error)")
        }
    }

    func testSave_whenValueIsNegative_throwsInvalidInput() async throws {
        // given / when / then
        do {
            try await sut.save(item: .amh, value: -1.0, date: Date(), note: nil)
            XCTFail("기대한 에러가 발생하지 않았습니다.")
        } catch AppError.invalidInput {
            // 정상
        } catch {
            XCTFail("예상치 못한 에러 타입: \(error)")
        }
    }

    // MARK: - savePGT

    func testSavePGT_withValidResult_savesToRepository() async throws {
        // given
        let result = PGTResult(normal: 3, abnormal: 1, mosaic: 0)

        // when
        try await sut.savePGT(item: .pgt, result: result, date: Date(), note: nil)

        // then
        XCTAssertEqual(repo.savedRecords.count, 1)
        XCTAssertEqual(repo.savedRecords.first?.pgtResult?.normal, 3)
    }

    func testSavePGT_withNumericItem_throwsInvalidInput() async throws {
        // given
        let result = PGTResult(normal: 2, abnormal: 0, mosaic: 0)

        // when / then
        do {
            try await sut.savePGT(item: .fsh, result: result, date: Date(), note: nil)
            XCTFail("기대한 에러가 발생하지 않았습니다.")
        } catch AppError.invalidInput {
            // 정상
        } catch {
            XCTFail("예상치 못한 에러 타입: \(error)")
        }
    }

    func testSavePGT_whenTotalIsZero_throwsInvalidInput() async throws {
        // given
        let result = PGTResult(normal: 0, abnormal: 0, mosaic: 0)

        // when / then
        do {
            try await sut.savePGT(item: .pgt, result: result, date: Date(), note: nil)
            XCTFail("기대한 에러가 발생하지 않았습니다.")
        } catch AppError.invalidInput {
            // 정상
        } catch {
            XCTFail("예상치 못한 에러 타입: \(error)")
        }
    }

    // MARK: - fetchLatestPerItem

    func testFetchLatestPerItem_groupsByTestItem() async throws {
        // given
        let fsh1 = makeRecord(item: .fsh, value: 5.0, date: Date(timeIntervalSinceNow: -86400))
        let fsh2 = makeRecord(item: .fsh, value: 6.0, date: Date())
        let amh = makeRecord(item: .amh, value: 1.5)
        repo.fetchAllResult = [fsh1, fsh2, amh]

        // when
        let result = try await sut.fetchLatestPerItem()

        // then
        XCTAssertEqual(result[.fsh]?.count, 2)
        XCTAssertEqual(result[.amh]?.count, 1)
    }

    func testFetchLatestPerItem_sortsByDateDescendingWithinGroup() async throws {
        // given
        let older = makeRecord(item: .fsh, value: 4.0, date: Date(timeIntervalSinceNow: -86400))
        let newer = makeRecord(item: .fsh, value: 7.0, date: Date())
        repo.fetchAllResult = [older, newer]

        // when
        let result = try await sut.fetchLatestPerItem()

        // then
        XCTAssertEqual(result[.fsh]?.first?.value, newer.value)
    }

    // MARK: - delete

    func testDelete_callsRepositoryWithCorrectID() async throws {
        // given
        let id = UUID()

        // when
        try await sut.delete(id: id)

        // then
        XCTAssertEqual(repo.deletedIDs, [id])
    }
}

// MARK: - Helpers

private extension HealthRecordUseCaseTests {
    func makeRecord(
        item: TestItem = .fsh,
        value: Double = 5.0,
        date: Date = Date()
    ) -> HealthRecord {
        HealthRecord(id: UUID(), testItem: item, value: value, date: date, note: nil, pgtResult: nil)
    }
}
