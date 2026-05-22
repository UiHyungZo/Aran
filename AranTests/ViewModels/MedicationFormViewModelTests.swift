@testable import Aran
import RxCocoa
import RxSwift
import XCTest

final class MedicationFormViewModelTests: XCTestCase {
    private var medicationRepo: MockMedicationRepository!
    private var notificationRepo: MockNotificationRepository!
    private var sut: MedicationFormViewModel!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        medicationRepo = MockMedicationRepository()
        notificationRepo = MockNotificationRepository()
        let useCase = MedicationUseCase(
            medicationRepository: medicationRepo,
            notificationRepository: notificationRepo
        )
        sut = MedicationFormViewModel(medicationUseCase: useCase)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        sut = nil
        disposeBag = nil
        medicationRepo = nil
        notificationRepo = nil
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

    func testIsSaveEnabled_whenDosageEmpty_isFalse() {
        // given
        let input = makeInput(drugName: "프로게스테론", dosage: "")

        // when
        let output = sut.transform(input: input)

        // then
        var result = true
        output.isSaveEnabled
            .drive(onNext: { result = $0 })
            .disposed(by: disposeBag)

        XCTAssertFalse(result)
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

    func testSave_onSuccess_emitsSaveCompleted() {
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
        wait(for: [expectation], timeout: 2.0)
    }

    func testSave_onFailure_emitsError() {
        // given
        medicationRepo.shouldThrow = AppError.storageError(NSError(domain: "test", code: -1))
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
        wait(for: [expectation], timeout: 2.0)
    }
}

// MARK: - Helpers

private extension MedicationFormViewModelTests {
    func makeInput(
        drugName: String = "",
        dosage: String = "",
        saveTapped: Observable<Void> = .empty()
    ) -> MedicationFormViewModel.Input {
        MedicationFormViewModel.Input(
            drugNameChanged: .just(drugName),
            typeSelected: .just(.oral),
            dosageChanged: .just(dosage),
            timesChanged: .just([Date()]),
            startDateChanged: .just(Date()),
            isNotificationEnabled: .just(false),
            saveTapped: saveTapped
        )
    }
}
