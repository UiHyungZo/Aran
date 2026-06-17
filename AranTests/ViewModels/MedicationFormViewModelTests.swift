@testable import Aran
import RxCocoa
import RxSwift
import XCTest
import AranDomain

@MainActor
final class MedicationFormViewModelTests: XCTestCase {
    private var mockUseCase: MockMedicationUseCase!
    private var sut: MedicationFormViewModel!
    private var disposeBag: DisposeBag!

    private var mockNotificationUseCase: MockMedicationNotificationUseCase!

    override func setUp() {
        super.setUp()
        mockUseCase = MockMedicationUseCase()
        mockNotificationUseCase = MockMedicationNotificationUseCase()
        sut = MedicationFormViewModel(
            medicationUseCase: mockUseCase,
            notificationUseCase: mockNotificationUseCase
        )
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        sut = nil
        disposeBag = nil
        mockUseCase = nil
        mockNotificationUseCase = nil
        super.tearDown()
    }

    // MARK: - isSaveEnabled

    func testIsSaveEnabled_whenBothFilled_isTrue() {
        // given
        let input = makeInput(drugName: "프로게스테론", dosage: "100mg")

        // when
        let output = sut.transform(input: input)

        // then
        var result = false
        output.isSaveEnabled
            .drive(onNext: { result = $0 })
            .disposed(by: disposeBag)

        XCTAssertTrue(result)
    }

    func testIsSaveEnabled_whenNameEmpty_isFalse() {
        // given
        let input = makeInput(drugName: "", dosage: "100mg")

        // when
        let output = sut.transform(input: input)

        // then
        var result = true
        output.isSaveEnabled
            .drive(onNext: { result = $0 })
            .disposed(by: disposeBag)

        XCTAssertFalse(result)
    }

    func testIsSaveEnabled_whenDosageEmpty_isTrue() {
        // given
        let input = makeInput(drugName: "프로게스테론", dosage: "")

        // when
        let output = sut.transform(input: input)

        // then
        var result = true
        output.isSaveEnabled
            .drive(onNext: { result = $0 })
            .disposed(by: disposeBag)

        XCTAssertTrue(result)
    }

    func testIsSaveEnabled_whenNameWhitespaceOnly_isFalse() {
        // given
        let input = makeInput(drugName: "   ", dosage: "100mg")

        // when
        let output = sut.transform(input: input)

        // then
        var result = true
        output.isSaveEnabled
            .drive(onNext: { result = $0 })
            .disposed(by: disposeBag)

        XCTAssertFalse(result)
    }

    // MARK: - saveCompleted

    func testSave_onSuccess_emitsSaveCompleted() async {
        // given
        let saveTapped = PublishSubject<Void>()
        let input = makeInput(drugName: "약A", dosage: "50mg", saveTapped: saveTapped.asObservable())
        let output = sut.transform(input: input)

        let expectation = XCTestExpectation(description: "saveCompleted emit")
        output.saveCompleted
            .drive(onNext: { expectation.fulfill() })
            .disposed(by: disposeBag)

        // when
        saveTapped.onNext(())

        // then
        await fulfillment(of: [expectation], timeout: 2.0)
    }

    func testSave_onFailure_emitsError() async {
        // given
        mockUseCase.shouldThrow = AppError.storageError(NSError(domain: "test", code: -1))
        let saveTapped = PublishSubject<Void>()
        let input = makeInput(drugName: "약A", dosage: "50mg", saveTapped: saveTapped.asObservable())
        let output = sut.transform(input: input)

        let expectation = XCTestExpectation(description: "error emit")
        output.error
            .filter { !$0.isEmpty }
            .drive(onNext: { _ in expectation.fulfill() })
            .disposed(by: disposeBag)

        // when
        saveTapped.onNext(())

        // then
        await fulfillment(of: [expectation], timeout: 2.0)
    }

    func testSave_whenInitialMedicationExists_updatesExistingMedication() async {
        // given
        let initialMedication = makeMedication(name: "기존약", dosage: "100mg")
        sut = MedicationFormViewModel(
            medicationUseCase: mockUseCase,
            notificationUseCase: mockNotificationUseCase,
            initialMedication: initialMedication
        )

        let saveTapped = PublishSubject<Void>()
        let input = makeInput(drugName: "수정약", dosage: "200mg", saveTapped: saveTapped.asObservable())
        let output = sut.transform(input: input)

        let expectation = XCTestExpectation(description: "update completed")
        output.saveCompleted
            .drive(onNext: { expectation.fulfill() })
            .disposed(by: disposeBag)

        // when
        saveTapped.onNext(())

        // then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockUseCase.savedMedications.isEmpty)
        XCTAssertEqual(mockUseCase.updatedMedications.first?.id, initialMedication.id)
        XCTAssertEqual(mockUseCase.updatedMedications.first?.drugName, "수정약")
        XCTAssertEqual(mockUseCase.updatedMedications.first?.dosage, "200mg")
    }

    func testSave_whenInitialMedicationExists_preservesMatchingTimeSlotID() async {
        // given
        let slotID = UUID()
        let medicationID = UUID()
        let existingTime = makeTime(hour: 9, minute: 30)
        let initialMedication = Medication(
            id: medicationID,
            drugName: "기존약",
            dosage: "100mg",
            type: .oral,
            schedule: MedicationSchedule(
                timeSlots: [
                    MedicationTimeSlot(
                        id: slotID,
                        time: existingTime,
                        isEnabled: true,
                        medicationID: medicationID
                    )
                ],
                startDate: Date(),
                endDate: nil
            ),
            isEnabled: true,
            notificationIDs: [],
            createdAt: Date()
        )
        sut = MedicationFormViewModel(
            medicationUseCase: mockUseCase,
            notificationUseCase: mockNotificationUseCase,
            initialMedication: initialMedication
        )

        let saveTapped = PublishSubject<Void>()
        let input = makeInput(
            drugName: "수정약",
            dosage: "200mg",
            times: [existingTime],
            saveTapped: saveTapped.asObservable()
        )
        let output = sut.transform(input: input)

        let expectation = XCTestExpectation(description: "update completed")
        output.saveCompleted
            .drive(onNext: { expectation.fulfill() })
            .disposed(by: disposeBag)

        // when
        saveTapped.onNext(())

        // then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(mockUseCase.updatedMedications.first?.schedule.timeSlots.first?.id, slotID)
    }

    func testDelete_onSuccess_emitsDeleteCompleted() async {
        // given
        let initialMedication = makeMedication(name: "기존약", dosage: "100mg")
        sut = MedicationFormViewModel(
            medicationUseCase: mockUseCase,
            notificationUseCase: mockNotificationUseCase,
            initialMedication: initialMedication
        )
        let deleteTapped = PublishSubject<Void>()
        let input = makeInput(drugName: "기존약", deleteTapped: deleteTapped.asObservable())
        let output = sut.transform(input: input)

        let expectation = XCTestExpectation(description: "deleteCompleted emit")
        output.deleteCompleted
            .drive(onNext: { expectation.fulfill() })
            .disposed(by: disposeBag)

        // when
        deleteTapped.onNext(())

        // then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(mockUseCase.deletedMedications.first?.id, initialMedication.id)
    }

    func testDelete_onFailure_emitsError() async {
        // given
        let initialMedication = makeMedication(name: "기존약", dosage: "100mg")
        mockUseCase.shouldThrow = AppError.storageError(NSError(domain: "test", code: -1))
        sut = MedicationFormViewModel(
            medicationUseCase: mockUseCase,
            notificationUseCase: mockNotificationUseCase,
            initialMedication: initialMedication
        )
        let deleteTapped = PublishSubject<Void>()
        let input = makeInput(drugName: "기존약", deleteTapped: deleteTapped.asObservable())
        let output = sut.transform(input: input)

        let expectation = XCTestExpectation(description: "error emit on delete failure")
        output.error
            .filter { !$0.isEmpty }
            .drive(onNext: { _ in expectation.fulfill() })
            .disposed(by: disposeBag)

        // when
        deleteTapped.onNext(())

        // then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockUseCase.deletedMedications.isEmpty)
    }

    func testSave_whenComponentFilled_savesComponent() async {
        // given
        let saveTapped = PublishSubject<Void>()
        let input = makeInput(
            drugName: "약A",
            component: "Follitropin alfa",
            dosage: "50mg",
            saveTapped: saveTapped.asObservable()
        )
        let output = sut.transform(input: input)

        let expectation = XCTestExpectation(description: "save completed")
        output.saveCompleted
            .drive(onNext: { expectation.fulfill() })
            .disposed(by: disposeBag)

        // when
        saveTapped.onNext(())

        // then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(mockUseCase.savedMedications.first?.component, "Follitropin alfa")
    }
}

// MARK: - Helpers

private extension MedicationFormViewModelTests {
    func makeInput(
        drugName: String = "",
        component: String = "",
        dosage: String = "",
        times: [Date] = [Date()],
        saveTapped: Observable<Void> = .empty(),
        deleteTapped: Observable<Void> = .empty()
    ) -> MedicationFormViewModel.Input {
        MedicationFormViewModel.Input(
            drugNameChanged: .just(drugName),
            typeSelected: .just(.oral),
            componentChanged: .just(component),
            dosageChanged: .just(dosage),
            timesChanged: .just(times),
            startDateChanged: .just(Date()),
            endDateChanged: .just(nil),
            isNotificationEnabled: .just(false),
            saveTapped: saveTapped,
            deleteTapped: deleteTapped
        )
    }

    func makeMedication(name: String, dosage: String) -> Medication {
        Medication(
            id: UUID(),
            drugName: name,
            dosage: dosage,
            type: .oral,
            schedule: MedicationSchedule(
                times: [Date()],
                startDate: Date(),
                endDate: nil
            ),
            isEnabled: false,
            notificationIDs: [],
            createdAt: Date()
        )
    }

    func makeTime(hour: Int, minute: Int = 0) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 1, hour: hour, minute: minute)) ?? Date()
    }
}
