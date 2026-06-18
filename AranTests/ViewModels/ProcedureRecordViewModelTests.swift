@testable import Aran
import XCTest
import AranDomain

@MainActor
final class ProcedureRecordViewModelTests: XCTestCase {
    private var cycleRecordUseCase: MockCycleRecordUseCase!
    private var transferRecordUseCase: MockTransferRecordUseCase!
    private var pgtRecordUseCase: MockPGTRecordUseCase!
    private var sut: ProcedureRecordViewModel!

    override func setUp() {
        super.setUp()
        cycleRecordUseCase = MockCycleRecordUseCase()
        transferRecordUseCase = MockTransferRecordUseCase()
        pgtRecordUseCase = MockPGTRecordUseCase()
        sut = ProcedureRecordViewModel(
            transferRecordUseCase: transferRecordUseCase,
            cycleRecordUseCase: cycleRecordUseCase,
            pgtRecordUseCase: pgtRecordUseCase
        )
    }

    override func tearDown() {
        sut = nil
        pgtRecordUseCase = nil
        transferRecordUseCase = nil
        cycleRecordUseCase = nil
        super.tearDown()
    }

    func testLoad_populatesCycleAndTransferAndPGTRecords() async {
        // given
        let cycleID = UUID()
        cycleRecordUseCase.stubbedAll = [makeCycleRecord(id: cycleID, cycleNumber: 1)]
        transferRecordUseCase.stubbedAll = [makeTransferRecord(cycleNumber: 1)]
        pgtRecordUseCase.stubbedAll = [makePGTRecord(cycleRecordId: cycleID)]

        // when
        await sut.load()

        // then
        XCTAssertEqual(sut.cycleRecords.count, 1)
        XCTAssertEqual(sut.transferRecords.count, 1)
        XCTAssertEqual(sut.pgtRecords.count, 1)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testLoad_onError_setsErrorMessage() async {
        // given
        cycleRecordUseCase.shouldThrow = AppError.storageError(NSError(domain: "test", code: -1))

        // when
        await sut.load()

        // then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func testCycleSummaries_mergesCycleAndTransferRecords() async {
        // given
        let cycleID = UUID()
        cycleRecordUseCase.stubbedAll = [makeCycleRecord(id: cycleID, cycleNumber: 2)]
        transferRecordUseCase.stubbedAll = [makeTransferRecord(cycleNumber: 2)]
        await sut.load()

        // when
        let summaries = sut.cycleSummaries

        // then
        XCTAssertEqual(summaries.count, 1)
        XCTAssertEqual(summaries.first?.cycleNumber, 2)
        XCTAssertEqual(summaries.first?.transferRecords.count, 1)
    }

    func testSaveCycleRecord_callsUseCaseAndReloads() async {
        // given
        let newCycle = makeCycleRecord(cycleNumber: 1)
        cycleRecordUseCase.stubbedAll = [newCycle]

        // when
        let success = await sut.saveCycleRecord(
            cycleNumber: 1,
            startDate: Date(),
            retrievalCount: 5,
            fertilizedCount: 4,
            frozenCount: 3,
            embryoRecords: []
        )

        // then
        XCTAssertTrue(success)
        XCTAssertEqual(sut.cycleRecords.count, 1)
    }

    func testDeleteCycleRecord_deletesTransferAndPGTThenCycle() async {
        // given
        let cycleID = UUID()
        let transfer = makeTransferRecord(cycleNumber: 1)
        let pgt = makePGTRecord(cycleRecordId: cycleID)
        cycleRecordUseCase.stubbedAll = [makeCycleRecord(id: cycleID, cycleNumber: 1)]
        transferRecordUseCase.stubbedAll = [transfer]
        pgtRecordUseCase.stubbedAll = [pgt]
        await sut.load()

        let summary = sut.cycleSummaries.first!

        // when
        await sut.deleteCycleRecord(summary: summary)

        // then
        XCTAssertTrue(transferRecordUseCase.deletedIDs.contains(transfer.id))
        XCTAssertTrue(pgtRecordUseCase.deletedIDs.contains(pgt.id))
    }

    func testSaveTransfer_callsUseCaseAndReloads() async {
        // given
        let date = Date()
        cycleRecordUseCase.stubbedAll = []
        transferRecordUseCase.stubbedAll = [makeTransferRecord(cycleNumber: 1)]

        // when
        let success = await sut.saveTransfer(
            cycleNumber: 1,
            date: date,
            embryoGrade: "4AA",
            embryoCount: 2,
            transferType: .frozen
        )

        // then
        XCTAssertTrue(success)
        XCTAssertEqual(transferRecordUseCase.savedRecords.count, 1)
        XCTAssertEqual(transferRecordUseCase.savedRecords.first?.embryoGrade, "4AA")
        XCTAssertEqual(cycleRecordUseCase.addedEvents.count, 1)
    }

    func testSavePGTRecord_callsUseCaseAndReloads() async {
        // given
        let cycleID = UUID()
        cycleRecordUseCase.stubbedAll = [makeCycleRecord(id: cycleID, cycleNumber: 1)]

        // when
        let success = await sut.savePGTRecord(
            cycleRecordId: cycleID,
            testDate: Date(),
            type: .pgtA,
            normalCount: 3,
            abnormalCount: 1,
            mosaicCount: 0,
            memo: nil
        )

        // then
        XCTAssertTrue(success)
    }

    func testChartData_returnsEntriesFilteredByPositiveCount() async {
        // given
        cycleRecordUseCase.stubbedAll = [makeCycleRecord(id: UUID(), cycleNumber: 1, retrievalCount: 5, fertilizedCount: 4, frozenCount: 3)]
        transferRecordUseCase.stubbedAll = [makeTransferRecord(cycleNumber: 1, embryoCount: 2)]
        await sut.load()

        // when
        let entries = sut.chartData()

        // then
        XCTAssertFalse(entries.isEmpty)
        XCTAssertTrue(entries.allSatisfy { !$0.isEmpty })
        let categories = Set(entries.map(\.category))
        XCTAssertTrue(categories.contains("채취"))
        XCTAssertTrue(categories.contains("이식"))
    }
}

// MARK: - Helpers

private extension ProcedureRecordViewModelTests {
    func makeCycleRecord(
        id: UUID = UUID(),
        cycleNumber: Int = 1,
        retrievalCount: Int = 0,
        fertilizedCount: Int = 0,
        frozenCount: Int = 0
    ) -> CycleRecord {
        CycleRecord(
            id: id,
            cycleNumber: cycleNumber,
            date: Date(),
            retrievalCount: retrievalCount,
            fertilizedCount: fertilizedCount,
            frozenCount: frozenCount,
            embryoRecords: [],
            events: [],
            diary: nil
        )
    }

    func makeTransferRecord(cycleNumber: Int = 1, embryoCount: Int = 1) -> TransferRecord {
        TransferRecord(
            id: UUID(),
            cycleNumber: cycleNumber,
            date: Date(),
            embryoGrade: "4AA",
            embryoCount: embryoCount,
            transferType: .frozen,
            result: .waiting,
            memo: nil
        )
    }

    func makePGTRecord(cycleRecordId: UUID = UUID()) -> PGTRecord {
        PGTRecord(
            id: UUID(),
            cycleRecordId: cycleRecordId,
            testDate: Date(),
            type: .pgtA,
            normalCount: 2,
            abnormalCount: 1,
            mosaicCount: 0
        )
    }
}
