@testable import Aran
import RxCocoa
import RxSwift
import XCTest

@MainActor
final class HealthRecordFormViewModelTests: XCTestCase {
    private var useCase: MockHealthRecordUseCase!
    private var sut: HealthRecordFormViewModel!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        useCase = MockHealthRecordUseCase()
        sut = HealthRecordFormViewModel(useCase: useCase)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        disposeBag = nil
        sut = nil
        useCase = nil
        super.tearDown()
    }

    func testIsSaveEnabled_whenValueIsInvalid_isFalse() {
        // given
        let input = makeInput(valueText: .just("abc"))

        // when
        let output = sut.transform(input: input)

        // then
        var result = true
        output.isSaveEnabled
            .drive(onNext: { result = $0 })
            .disposed(by: disposeBag)
        XCTAssertFalse(result)
    }

    func testSave_whenAddMode_savesRecord() async {
        // given
        let saveTap = PublishSubject<Void>()
        let input = makeInput(saveTap: saveTap.asObservable())
        let output = sut.transform(input: input)

        let expectation = XCTestExpectation(description: "saved")
        output.saved
            .drive(onNext: { expectation.fulfill() })
            .disposed(by: disposeBag)

        // when
        saveTap.onNext(())

        // then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(useCase.savedRecords.first?.type, HealthRecordType.fsh)
        XCTAssertEqual(useCase.savedRecords.first?.value, 7.2)
    }

    func testSave_whenAddLockedMode_ignoresSelectedTypeAndSavesLockedType() async {
        // given
        sut = HealthRecordFormViewModel(useCase: useCase, mode: .addLocked(type: HealthRecordType.amh))

        let saveTap = PublishSubject<Void>()
        let input = makeInput(
            selectedType: .just(HealthRecordType.fsh),
            unitText: .just("ng/mL"),
            saveTap: saveTap.asObservable()
        )
        let output = sut.transform(input: input)

        let expectation = XCTestExpectation(description: "saved")
        output.saved
            .drive(onNext: { expectation.fulfill() })
            .disposed(by: disposeBag)

        // when
        saveTap.onNext(())

        // then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(useCase.savedRecords.first?.type, HealthRecordType.amh)
        XCTAssertEqual(useCase.savedRecords.first?.unit, "ng/mL")
    }

    func testInitialUnitText_whenAddLockedModeUsesLatestRecordUnit() async {
        // given
        let older = makeRecord(type: "비타민D", unit: "ng/mL", date: Date(timeIntervalSinceNow: -86400))
        let newer = makeRecord(type: "비타민D", unit: "IU/L", date: Date())
        useCase.stubbedByType = [newer, older]
        sut = HealthRecordFormViewModel(useCase: useCase, mode: .addLocked(type: "비타민D"))

        let output = sut.transform(input: makeInput())

        let expectation = XCTestExpectation(description: "initial unit")
        var result = ""
        output.initialUnitText
            .drive(onNext: {
                result = $0
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(result, "IU/L")
    }

    func testInitialUnitText_whenAddLockedModeHasNoRecordsUsesDefaultUnit() async {
        // given
        sut = HealthRecordFormViewModel(useCase: useCase, mode: .addLocked(type: HealthRecordType.amh))

        let output = sut.transform(input: makeInput())

        let expectation = XCTestExpectation(description: "default unit")
        var result = ""
        output.initialUnitText
            .drive(onNext: {
                result = $0
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(result, "ng/mL")
    }

    func testSave_whenEditMode_updatesExistingRecordID() async {
        // given
        let record = makeRecord(value: 6.8)
        sut = HealthRecordFormViewModel(useCase: useCase, mode: .edit(record: record))

        let saveTap = PublishSubject<Void>()
        let input = makeInput(valueText: .just("8.0"), saveTap: saveTap.asObservable())
        let output = sut.transform(input: input)

        let expectation = XCTestExpectation(description: "updated")
        output.saved
            .drive(onNext: { expectation.fulfill() })
            .disposed(by: disposeBag)

        // when
        saveTap.onNext(())

        // then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(useCase.updatedRecords.first?.id, record.id)
        XCTAssertEqual(useCase.updatedRecords.first?.value, 8.0)
    }

    func testDelete_whenEditMode_deletesRecord() async {
        // given
        let record = makeRecord()
        sut = HealthRecordFormViewModel(useCase: useCase, mode: .edit(record: record))

        let deleteTap = PublishSubject<Void>()
        let input = makeInput(deleteTap: deleteTap.asObservable())
        let output = sut.transform(input: input)

        let expectation = XCTestExpectation(description: "deleted")
        output.deleted
            .drive(onNext: { expectation.fulfill() })
            .disposed(by: disposeBag)

        // when
        deleteTap.onNext(())

        // then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(useCase.deletedIDs, [record.id])
    }
}

private extension HealthRecordFormViewModelTests {
    func makeInput(
        selectedType: Observable<String> = .just(HealthRecordType.fsh),
        valueText: Observable<String> = .just("7.2"),
        unitText: Observable<String> = .just("mIU/mL"),
        date: Observable<Date> = .just(Date()),
        memo: Observable<String?> = .just(nil),
        saveTap: Observable<Void> = .empty(),
        deleteTap: Observable<Void> = .empty()
    ) -> HealthRecordFormViewModel.Input {
        HealthRecordFormViewModel.Input(
            selectedType: selectedType,
            valueText: valueText,
            unitText: unitText,
            date: date,
            memo: memo,
            saveTap: saveTap,
            deleteTap: deleteTap
        )
    }

    func makeRecord(
        type: String = HealthRecordType.fsh,
        value: Double = 7.2,
        unit: String = "mIU/mL",
        date: Date = Date()
    ) -> HealthRecord {
        HealthRecord(
            id: UUID(),
            type: type,
            value: value,
            unit: unit,
            recordDate: date,
            memo: nil
        )
    }
}
