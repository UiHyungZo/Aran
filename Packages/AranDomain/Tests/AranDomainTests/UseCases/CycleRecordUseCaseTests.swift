import XCTest
import AranDomain

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

    // MARK: - save

    func testSave_withValidInput_savesRecord() async throws {
        // when
        try await sut.save(cycleNumber: 1, startDate: Date(), retrievalCount: 5, fertilizedCount: 3, frozenCount: 2, embryoRecords: [])

        // then
        XCTAssertEqual(repo.savedRecords.count, 1)
        XCTAssertEqual(repo.savedRecords.first?.cycleNumber, 1)
    }

    func testSave_withRetrievalCount_addsEmbryoRetrievalEvent() async throws {
        // when
        try await sut.save(cycleNumber: 1, startDate: Date(), retrievalCount: 4, fertilizedCount: 2, frozenCount: 1, embryoRecords: [])

        // then
        let events = repo.savedRecords.first?.events ?? []
        guard case .embryoRetrieval(let count) = events.first else {
            return XCTFail("embryoRetrieval 이벤트 없음")
        }
        XCTAssertEqual(count, 4)
    }

    func testSave_withZeroCycleNumber_throws() async {
        // when / then
        await XCTAssertThrowsErrorAsync(
            try await sut.save(cycleNumber: 0, startDate: Date(), retrievalCount: 0, fertilizedCount: 0, frozenCount: 0, embryoRecords: [])
        )
    }

    func testSave_whenFertilizedExceedsRetrieval_throws() async {
        // when / then
        await XCTAssertThrowsErrorAsync(
            try await sut.save(cycleNumber: 1, startDate: Date(), retrievalCount: 3, fertilizedCount: 5, frozenCount: 0, embryoRecords: [])
        )
    }

    func testSave_whenFrozenExceedsFertilized_throws() async {
        // when / then
        await XCTAssertThrowsErrorAsync(
            try await sut.save(cycleNumber: 1, startDate: Date(), retrievalCount: 5, fertilizedCount: 3, frozenCount: 4, embryoRecords: [])
        )
    }

    // MARK: - update

    func testUpdate_whenRecordExists_updatesRecord() async throws {
        // given
        let record = makeCycleRecord(cycleNumber: 2)
        repo.fetchAllResult = [record]

        // when
        try await sut.update(cycleNumber: 2, startDate: Date(), retrievalCount: 6, fertilizedCount: 4, frozenCount: 2, embryoRecords: [])

        // then
        XCTAssertEqual(repo.updatedRecords.count, 1)
        XCTAssertEqual(repo.updatedRecords.first?.fertilizedCount, 4)
    }

    func testUpdate_whenRecordNotFound_throws() async {
        // given
        repo.fetchAllResult = []

        // when / then
        await XCTAssertThrowsErrorAsync(
            try await sut.update(cycleNumber: 99, startDate: Date(), retrievalCount: 0, fertilizedCount: 0, frozenCount: 0, embryoRecords: [])
        )
    }

    func testUpdate_updatesEmbryoRetrievalEventCount() async throws {
        // given
        let record = makeCycleRecord(cycleNumber: 1, events: [.embryoRetrieval(count: 3)])
        repo.fetchAllResult = [record]

        // when
        try await sut.update(cycleNumber: 1, startDate: Date(), retrievalCount: 7, fertilizedCount: 4, frozenCount: 2, embryoRecords: [])

        // then
        let events = repo.updatedRecords.first?.events ?? []
        guard case .embryoRetrieval(let count) = events.first else {
            return XCTFail("embryoRetrieval 이벤트 없음")
        }
        XCTAssertEqual(count, 7)
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

    // MARK: - removeTransferEvent

    func testRemoveTransferEvent_removesMatchingEvent() async throws {
        // given
        let transferID = UUID()
        let record = makeCycleRecord(events: [.embryoTransfer(transferID: transferID), .ovulation])
        repo.fetchAllResult = [record]

        // when
        try await sut.removeTransferEvent(transferID: transferID)

        // then
        XCTAssertEqual(repo.updatedRecords.count, 1)
        XCTAssertEqual(repo.updatedRecords.first?.events.count, 1)
    }

    func testRemoveTransferEvent_whenNoMatch_doesNotUpdate() async throws {
        // given
        let record = makeCycleRecord(events: [.ovulation])
        repo.fetchAllResult = [record]

        // when
        try await sut.removeTransferEvent(transferID: UUID())

        // then
        XCTAssertTrue(repo.updatedRecords.isEmpty)
    }

    // MARK: - clearDiary

    func testClearDiary_whenRecordExists_setsDiaryToNil() async throws {
        // given
        let diary = DiaryEntry(id: UUID(), date: Date(), emoji: "😊", content: "기록")
        let record = makeCycleRecord(diary: diary)
        repo.fetchDateResult = record

        // when
        try await sut.clearDiary(for: record.date)

        // then
        XCTAssertEqual(repo.updatedRecords.count, 1)
        XCTAssertNil(repo.updatedRecords.first?.diary)
    }

    func testClearDiary_whenNoRecord_doesNothing() async throws {
        // given
        repo.fetchDateResult = nil

        // when
        try await sut.clearDiary(for: Date())

        // then
        XCTAssertTrue(repo.updatedRecords.isEmpty)
    }

    // MARK: - addEvent (protocol extension convenience)

    func testAddEvent_convenienceOverload_usesCycleNumber1() async throws {
        // given
        repo.fetchDateResult = nil
        let sutProtocol: CycleRecordUseCaseProtocol = sut

        // when
        try await sutProtocol.addEvent(.ovulation, to: Date())

        // then
        XCTAssertEqual(repo.savedRecords.first?.cycleNumber, 1)
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

    func testEstimateOvulation_withCustomCycleLength_returnsCorrectDate() {
        // given
        let periodStart = Date(timeIntervalSince1970: 0)
        let expected = Calendar.current.date(byAdding: .day, value: 21, to: periodStart)!

        // when
        let result = sut.estimateOvulation(from: periodStart, cycleLength: 35)

        // then
        XCTAssertEqual(result, expected)
    }
}

// MARK: - Helpers

private extension CycleRecordUseCaseTests {
    func makeCycleRecord(cycleNumber: Int = 1, events: [DayEvent] = [], diary: DiaryEntry? = nil) -> CycleRecord {
        CycleRecord(id: UUID(), cycleNumber: cycleNumber, date: Date(), events: events, diary: diary)
    }
}

// MARK: - Async throw helper

private func XCTAssertThrowsErrorAsync(_ expression: @autoclosure () async throws -> some Any) async {
    do {
        _ = try await expression()
        XCTFail("에러가 발생해야 합니다.")
    } catch {}
}
