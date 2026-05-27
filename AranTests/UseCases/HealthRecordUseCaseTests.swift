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

    func test_fetchAll_whenRepositoryReturnsRecords_thenReturnsAllRecords() async throws {
        // given
        let expected = [makeRecord(type: HealthRecordType.fsh), makeRecord(type: HealthRecordType.amh)]
        repo.fetchAllResult = expected

        // when
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.map(\.type), expected.map(\.type))
    }

    func test_fetch_whenRecordsAreUnsorted_thenSortsByDateDescending() async throws {
        // given
        let older = makeRecord(value: 4.0, date: Date(timeIntervalSinceNow: -86400))
        let newer = makeRecord(value: 6.0, date: Date())
        repo.fetchTypeResult = [older, newer]

        // when
        let result = try await sut.fetch(type: HealthRecordType.fsh)

        // then
        XCTAssertEqual(result.first?.value, newer.value)
        XCTAssertEqual(result.last?.value, older.value)
    }

    func test_save_whenInputIsValid_thenSavesToRepository() async throws {
        // given / when
        try await sut.save(type: HealthRecordType.fsh, value: 5.2, unit: "mIU/mL", recordDate: Date(), memo: nil)

        // then
        XCTAssertEqual(repo.savedRecords.count, 1)
        XCTAssertEqual(repo.savedRecords.first?.type, HealthRecordType.fsh)
        XCTAssertEqual(repo.savedRecords.first?.unit, "mIU/mL")
    }

    func test_save_whenCustomTypeIsValid_thenSavesToRepository() async throws {
        // given / when
        try await sut.save(type: "비타민D", value: 31, unit: "ng/mL", recordDate: Date(), memo: "외부 검사")

        // then
        XCTAssertEqual(repo.savedRecords.first?.type, "비타민D")
        XCTAssertEqual(repo.savedRecords.first?.memo, "외부 검사")
    }

    func test_save_whenTypeIsEmpty_thenThrowsInvalidInput() async throws {
        // given / when / then
        do {
            try await sut.save(type: " ", value: 5.2, unit: "mIU/mL", recordDate: Date(), memo: nil)
            XCTFail("기대한 에러가 발생하지 않았습니다.")
        } catch AppError.invalidInput {
            // expected
        } catch {
            XCTFail("예상치 못한 에러 타입: \(error)")
        }
    }

    func test_save_whenValueIsZero_thenThrowsInvalidInput() async throws {
        // given / when / then
        do {
            try await sut.save(type: HealthRecordType.fsh, value: 0, unit: "mIU/mL", recordDate: Date(), memo: nil)
            XCTFail("기대한 에러가 발생하지 않았습니다.")
        } catch AppError.invalidInput {
            // expected
        } catch {
            XCTFail("예상치 못한 에러 타입: \(error)")
        }
    }

    func test_save_whenUnitIsEmpty_thenThrowsInvalidInput() async throws {
        // given / when / then
        do {
            try await sut.save(type: HealthRecordType.amh, value: 1.0, unit: "", recordDate: Date(), memo: nil)
            XCTFail("기대한 에러가 발생하지 않았습니다.")
        } catch AppError.invalidInput {
            // expected
        } catch {
            XCTFail("예상치 못한 에러 타입: \(error)")
        }
    }

    func test_update_whenRecordIsValid_thenUpdatesRepository() async throws {
        // given
        let record = makeRecord(value: 7.0)

        // when
        try await sut.update(record)

        // then
        XCTAssertEqual(repo.updatedRecords.first?.id, record.id)
        XCTAssertEqual(repo.updatedRecords.first?.value, 7.0)
    }

    func test_fetchLatestPerItem_whenMultipleTypes_thenGroupsByType() async throws {
        // given
        let fsh1 = makeRecord(type: HealthRecordType.fsh, value: 5.0, date: Date(timeIntervalSinceNow: -86400))
        let fsh2 = makeRecord(type: HealthRecordType.fsh, value: 6.0, date: Date())
        let amh = makeRecord(type: HealthRecordType.amh, value: 1.5)
        repo.fetchAllResult = [fsh1, fsh2, amh]

        // when
        let result = try await sut.fetchLatestPerItem()

        // then
        XCTAssertEqual(result[HealthRecordType.fsh]?.count, 2)
        XCTAssertEqual(result[HealthRecordType.amh]?.count, 1)
    }

    func test_fetchLatestPerItem_whenGrouped_thenSortsByDateDescendingWithinGroup() async throws {
        // given
        let older = makeRecord(value: 4.0, date: Date(timeIntervalSinceNow: -86400))
        let newer = makeRecord(value: 7.0, date: Date())
        repo.fetchAllResult = [older, newer]

        // when
        let result = try await sut.fetchLatestPerItem()

        // then
        XCTAssertEqual(result[HealthRecordType.fsh]?.first?.value, newer.value)
    }

    func test_delete_whenIdIsProvided_thenCallsRepositoryWithCorrectID() async throws {
        // given
        let id = UUID()

        // when
        try await sut.delete(id: id)

        // then
        XCTAssertEqual(repo.deletedIDs, [id])
    }
}

private extension HealthRecordUseCaseTests {
    func makeRecord(
        type: String = HealthRecordType.fsh,
        value: Double = 5.0,
        unit: String = "mIU/mL",
        date: Date = Date(),
        memo: String? = nil
    ) -> HealthRecord {
        HealthRecord(id: UUID(), type: type, value: value, unit: unit, recordDate: date, memo: memo)
    }
}
