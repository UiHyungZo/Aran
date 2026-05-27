@testable import Aran
import XCTest

final class CycleRecordUseCaseTests: XCTestCase {
    private var repo: MockCycleRecordRepository!
    private var sut: CycleRecordUseCase!

    override func setUp() {
        super.setUp()
        repo = MockCycleRecordRepository()
        sut = CycleRecordUseCase(repository: repo)
    }

    override func tearDown() {
        sut = nil
        repo = nil
        super.tearDown()
    }

    // MARK: - fetchAll

    func testFetchAll_returnsAllRecords() async throws {
        // given
        let expected = [makeCycleRecord(), makeCycleRecord()]
        repo.fetchAllResult = expected

        // when
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.count, expected.count)
    }

    // MARK: - fetch(date:)

    func testFetch_whenRecordExists_returnsRecord() async throws {
        // given
        let record = makeCycleRecord()
        repo.fetchDateResult = record

        // when
        let result = try await sut.fetch(date: record.date)

        // then
        XCTAssertEqual(result?.id, record.id)
    }

    func testFetch_whenNoRecord_returnsNil() async throws {
        // given
        repo.fetchDateResult = nil

        // when
        let result = try await sut.fetch(date: Date())

        // then
        XCTAssertNil(result)
    }

    // MARK: - addEvent

    func testAddEvent_whenRecordExists_updatesExistingRecord() async throws {
        // given
        let existing = makeCycleRecord(events: [.ovulation])
        repo.fetchDateResult = existing

        // when
        try await sut.addEvent(.periodStart, to: existing.date)

        // then
        XCTAssertEqual(repo.updatedRecords.count, 1)
        XCTAssertTrue(repo.savedRecords.isEmpty)
        XCTAssertEqual(repo.updatedRecords.first?.events.count, 2)
    }

    func testAddEvent_whenNoRecord_savesNewRecord() async throws {
        // given
        repo.fetchDateResult = nil

        // when
        try await sut.addEvent(.ovulation, to: Date())

        // then
        XCTAssertEqual(repo.savedRecords.count, 1)
        XCTAssertTrue(repo.updatedRecords.isEmpty)
        XCTAssertEqual(repo.savedRecords.first?.events.count, 1)
    }

    func testAddEvent_whenNoRecordAndCycleNumberProvided_savesCycleNumber() async throws {
        // given
        repo.fetchDateResult = nil

        // when
        try await sut.addEvent(.embryoTransfer(transferID: UUID()), to: Date(), cycleNumber: 3)

        // then
        XCTAssertEqual(repo.savedRecords.first?.cycleNumber, 3)
    }

    // MARK: - saveDiary

    func testSaveDiary_whenRecordExists_updatesExistingRecord() async throws {
        // given
        let existing = makeCycleRecord()
        repo.fetchDateResult = existing

        // when
        try await sut.saveDiary(emoji: "😊", text: "기분 좋은 하루", for: existing.date)

        // then
        XCTAssertEqual(repo.updatedRecords.count, 1)
        XCTAssertTrue(repo.savedRecords.isEmpty)
        XCTAssertEqual(repo.updatedRecords.first?.diary?.emoji, "😊")
    }

    func testSaveDiary_whenNoRecord_savesNewRecord() async throws {
        // given
        repo.fetchDateResult = nil

        // when
        try await sut.saveDiary(emoji: nil, text: "첫 기록", for: Date())

        // then
        XCTAssertEqual(repo.savedRecords.count, 1)
        XCTAssertTrue(repo.updatedRecords.isEmpty)
        XCTAssertEqual(repo.savedRecords.first?.diary?.text, "첫 기록")
    }

    // MARK: - estimateOvulation

    func testEstimateOvulation_returns14DaysAfterPeriodStart() {
        // given
        let periodStart = Date(timeIntervalSince1970: 0)
        let expected = Calendar.current.date(byAdding: .day, value: 14, to: periodStart)!

        // when
        let result = sut.estimateOvulation(from: periodStart)

        // then
        XCTAssertEqual(result, expected)
    }
}

// MARK: - Helpers

private extension CycleRecordUseCaseTests {
    func makeCycleRecord(events: [DayEvent] = []) -> CycleRecord {
        CycleRecord(id: UUID(), date: Date(), events: events, diary: nil)
    }
}
