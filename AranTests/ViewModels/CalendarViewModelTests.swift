@testable import Aran
import XCTest

@MainActor
final class CalendarViewModelTests: XCTestCase {
    private var cycleRecordUseCase: MockCycleRecordUseCase!
    private var healthRecordUseCase: MockHealthRecordUseCase!
    private var transferRecordUseCase: MockTransferRecordUseCase!
    private var medicationUseCase: MockMedicationUseCase!
    private var hospitalVisitUseCase: MockHospitalVisitUseCase!
    private var menstrualCycleUseCase: MockMenstrualCycleUseCase!
    private var medicationLogUseCase: MockMedicationLogUseCase!
    private var diaryEntryUseCase: MockDiaryEntryUseCase!
    private var sut: CalendarViewModel!

    override func setUp() {
        super.setUp()
        cycleRecordUseCase = MockCycleRecordUseCase()
        healthRecordUseCase = MockHealthRecordUseCase()
        transferRecordUseCase = MockTransferRecordUseCase()
        medicationUseCase = MockMedicationUseCase()
        hospitalVisitUseCase = MockHospitalVisitUseCase()
        menstrualCycleUseCase = MockMenstrualCycleUseCase()
        medicationLogUseCase = MockMedicationLogUseCase()
        diaryEntryUseCase = MockDiaryEntryUseCase()
        sut = makeViewModel()
    }

    override func tearDown() {
        sut = nil
        diaryEntryUseCase = nil
        medicationLogUseCase = nil
        menstrualCycleUseCase = nil
        hospitalVisitUseCase = nil
        medicationUseCase = nil
        transferRecordUseCase = nil
        healthRecordUseCase = nil
        cycleRecordUseCase = nil
        super.tearDown()
    }

    func testLoadMonthRecords_whenCycleRecordsHaveSameDay_mergesEventsWithoutCrash() async {
        // given
        let day = Calendar.current.startOfDay(for: Date())
        let transferID = UUID()
        cycleRecordUseCase.stubbedAll = [
            makeCycleRecord(
                date: day,
                retrievalCount: 2,
                events: [.embryoRetrieval(count: 2)]
            ),
            makeCycleRecord(
                date: Calendar.current.date(byAdding: .hour, value: 9, to: day)!,
                retrievalCount: 1,
                events: [.embryoTransfer(transferID: transferID)]
            ),
        ]

        // when
        await sut.loadMonthRecords()

        // then
        let events = sut.events(for: day)
        XCTAssertEqual(sut.cycleRecords.count, 1)
        XCTAssertEqual(sut.cycleRecords[day]?.retrievalCount, 2)
        XCTAssertTrue(events.containsEmbryoRetrieval(count: 2))
        XCTAssertTrue(events.containsEmbryoTransfer(id: transferID))
    }

    func testSaveTransfer_whenCalled_savesRecordAndAddsTransferEvent() async {
        // given
        let day = Calendar.current.startOfDay(for: Date())
        sut.selectedDate = day

        // when
        let result = await sut.saveTransfer(
            cycleNumber: 2,
            date: day,
            embryoGrade: "4AA",
            embryoCount: 2,
            transferType: .frozen,
            result: .waiting,
            memo: "메모"
        )

        // then
        XCTAssertTrue(result)
        XCTAssertEqual(transferRecordUseCase.savedRecords.count, 1)
        XCTAssertEqual(transferRecordUseCase.savedRecords.first?.cycleNumber, 2)
        XCTAssertEqual(transferRecordUseCase.savedRecords.first?.embryoGrade, "4AA")
        XCTAssertEqual(transferRecordUseCase.savedRecords.first?.embryoCount, 2)
        XCTAssertEqual(transferRecordUseCase.savedRecords.first?.memo, "메모")
        XCTAssertEqual(cycleRecordUseCase.addedEvents.count, 1)
        XCTAssertEqual(cycleRecordUseCase.addedEvents.first?.cycleNumber, 2)
        guard case .embryoTransfer = cycleRecordUseCase.addedEvents.first?.event else {
            return XCTFail("embryoTransfer 이벤트가 추가되어야 합니다.")
        }
    }

    func testUpdateTransfer_whenCalled_updatesRecordAndRewiresTransferEvent() async {
        // given
        let id = UUID()
        let oldDate = Calendar.current.startOfDay(for: Date())
        let newDate = Calendar.current.date(byAdding: .day, value: -1, to: oldDate)!
        transferRecordUseCase.stubbedRecord = TransferRecord(
            id: id,
            cycleNumber: 1,
            date: oldDate,
            embryoGrade: "3AA",
            embryoCount: 1,
            transferType: .fresh,
            result: .waiting,
            memo: nil
        )
        sut.selectedDate = oldDate

        // when
        let result = await sut.updateTransfer(
            id: id,
            cycleNumber: 3,
            date: newDate,
            embryoGrade: "5AA",
            embryoCount: 2,
            transferType: .frozen,
            result: .pregnant,
            memo: "수정 메모"
        )

        // then
        XCTAssertTrue(result)
        XCTAssertEqual(transferRecordUseCase.updatedRecords.count, 1)
        XCTAssertEqual(transferRecordUseCase.updatedRecords.first?.cycleNumber, 3)
        XCTAssertEqual(transferRecordUseCase.updatedRecords.first?.date, newDate)
        XCTAssertEqual(transferRecordUseCase.updatedRecords.first?.embryoGrade, "5AA")
        XCTAssertEqual(transferRecordUseCase.updatedRecords.first?.embryoCount, 2)
        XCTAssertEqual(transferRecordUseCase.updatedRecords.first?.transferType, .frozen)
        XCTAssertEqual(transferRecordUseCase.updatedRecords.first?.result, .pregnant)
        XCTAssertEqual(transferRecordUseCase.updatedRecords.first?.memo, "수정 메모")
        XCTAssertEqual(cycleRecordUseCase.removedTransferIDs, [id])
        XCTAssertEqual(cycleRecordUseCase.addedEvents.last?.cycleNumber, 3)
        XCTAssertEqual(cycleRecordUseCase.addedEvents.last?.date, newDate)
        guard case let .embryoTransfer(transferID) = cycleRecordUseCase.addedEvents.last?.event else {
            return XCTFail("embryoTransfer 이벤트가 다시 연결되어야 합니다.")
        }
        XCTAssertEqual(transferID, id)
    }

    func testDeleteTransfer_whenCalled_deletesRecordAndRemovesTransferEvent() async {
        // given
        let id = UUID()

        // when
        let result = await sut.deleteTransfer(id: id)

        // then
        XCTAssertTrue(result)
        XCTAssertEqual(transferRecordUseCase.deletedIDs, [id])
        XCTAssertEqual(cycleRecordUseCase.removedTransferIDs, [id])
    }

    func testUpdateHealthRecord_whenCalled_updatesRecord() async {
        // given
        let record = HealthRecord(
            id: UUID(),
            type: HealthRecordType.fsh,
            value: 8.5,
            unit: "mIU/mL",
            recordDate: Date(),
            memo: "수정"
        )

        // when
        await sut.updateHealthRecord(record)

        // then
        XCTAssertEqual(healthRecordUseCase.updatedRecords.count, 1)
        XCTAssertEqual(healthRecordUseCase.updatedRecords.first?.id, record.id)
        XCTAssertNil(sut.errorMessage)
    }

    func testDeleteHealthRecord_whenCalled_deletesRecord() async {
        // given
        let id = UUID()

        // when
        await sut.deleteHealthRecord(id: id)

        // then
        XCTAssertEqual(healthRecordUseCase.deletedIDs, [id])
        XCTAssertNil(sut.errorMessage)
    }

    func testUpdateHealthRecord_whenUseCaseThrows_setsErrorMessage() async {
        // given
        healthRecordUseCase.shouldThrow = AppError.invalidInput("유효한 수치를 입력해주세요.")
        let record = HealthRecord(
            id: UUID(),
            type: HealthRecordType.fsh,
            value: 0,
            unit: "mIU/mL",
            recordDate: Date(),
            memo: nil
        )

        // when
        await sut.updateHealthRecord(record)

        // then
        XCTAssertEqual(sut.errorMessage, "유효한 수치를 입력해주세요.")
    }
}

private extension CalendarViewModelTests {
    func makeViewModel() -> CalendarViewModel {
        CalendarViewModel(
            cycleRecordUseCase: cycleRecordUseCase,
            healthRecordUseCase: healthRecordUseCase,
            transferRecordUseCase: transferRecordUseCase,
            medicationUseCase: medicationUseCase,
            hospitalVisitUseCase: hospitalVisitUseCase,
            menstrualCycleUseCase: menstrualCycleUseCase,
            medicationLogUseCase: medicationLogUseCase,
            diaryEntryUseCase: diaryEntryUseCase
        )
    }

    func makeCycleRecord(
        date: Date,
        retrievalCount: Int,
        events: [DayEvent]
    ) -> CycleRecord {
        CycleRecord(
            id: UUID(),
            date: date,
            retrievalCount: retrievalCount,
            events: events,
            diary: nil
        )
    }
}

private extension [DayEvent] {
    func containsEmbryoRetrieval(count: Int) -> Bool {
        contains {
            guard case let .embryoRetrieval(value) = $0 else { return false }
            return value == count
        }
    }

    func containsEmbryoTransfer(id: UUID) -> Bool {
        contains {
            guard case let .embryoTransfer(value) = $0 else { return false }
            return value == id
        }
    }
}
