@testable import Aran
import RxCocoa
import RxSwift
import XCTest

@MainActor
final class MedicationViewModelTests: XCTestCase {
    private var mockUseCase: MockMedicationUseCase!
    private var sut: MedicationViewModel!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        mockUseCase = MockMedicationUseCase()
        sut = MedicationViewModel(medicationUseCase: mockUseCase)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        sut = nil
        disposeBag = nil
        mockUseCase = nil
        super.tearDown()
    }

    func testViewDidLoad_loadsAndEmitsMedications() {
        // given
        let med = makeMedication(name: "프로게스테론")
        mockUseCase.stubbedMedications = [med]
        let viewDidLoad = PublishSubject<Void>()
        let output = sut.transform(input: makeInput(viewDidLoad: viewDidLoad.asObservable()))

        let expectation = XCTestExpectation(description: "medications emitted")
        var result: [Medication] = []
        output.medications
            .skip(1)
            .drive(onNext: {
                result = $0
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // when
        viewDidLoad.onNext(())

        // then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.drugName, "프로게스테론")
    }

    func testViewDidLoad_onError_emitsErrorMessage() {
        // given
        mockUseCase.shouldThrow = AppError.storageError(NSError(domain: "test", code: -1))
        let viewDidLoad = PublishSubject<Void>()
        let output = sut.transform(input: makeInput(viewDidLoad: viewDidLoad.asObservable()))

        let expectation = XCTestExpectation(description: "error emitted")
        output.error
            .filter { !$0.isEmpty }
            .drive(onNext: { _ in expectation.fulfill() })
            .disposed(by: disposeBag)

        // when
        viewDidLoad.onNext(())

        // then
        wait(for: [expectation], timeout: 2.0)
    }

    func testToggleMedication_callsUseCaseAndReloads() {
        // given
        let med = makeMedication(name: "클로미펜")
        let toggle = PublishSubject<Medication>()
        let output = sut.transform(input: makeInput(toggleMedication: toggle.asObservable()))

        let expectation = XCTestExpectation(description: "reload after toggle")
        output.medications
            .skip(1)
            .drive(onNext: { _ in expectation.fulfill() })
            .disposed(by: disposeBag)

        // when
        toggle.onNext(med)

        // then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockUseCase.toggledMedications.first?.id, med.id)
    }

    func testToggleTimeSlot_callsUseCaseAndReloads() {
        // given
        let med = makeMedication(name: "에스트로겐")
        let slotID = UUID()
        let toggle = PublishSubject<MedicationViewModel.TimeSlotToggleRequest>()
        let output = sut.transform(input: makeInput(toggleTimeSlot: toggle.asObservable()))

        let expectation = XCTestExpectation(description: "reload after timeslot toggle")
        output.medications
            .skip(1)
            .drive(onNext: { _ in expectation.fulfill() })
            .disposed(by: disposeBag)

        // when
        toggle.onNext(MedicationViewModel.TimeSlotToggleRequest(medication: med, timeSlotID: slotID))

        // then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockUseCase.toggledTimeSlots.first?.medication.id, med.id)
        XCTAssertEqual(mockUseCase.toggledTimeSlots.first?.slotID, slotID)
    }

    func testDeleteMedication_callsUseCaseAndReloads() {
        // given
        let med = makeMedication(name: "황체호르몬")
        let delete = PublishSubject<Medication>()
        let output = sut.transform(input: makeInput(deleteMedication: delete.asObservable()))

        let expectation = XCTestExpectation(description: "reload after delete")
        output.medications
            .skip(1)
            .drive(onNext: { _ in expectation.fulfill() })
            .disposed(by: disposeBag)

        // when
        delete.onNext(med)

        // then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(mockUseCase.deletedMedications.first?.id, med.id)
    }

    func testViewDidLoad_setsIsLoadingFalseAfterLoad() {
        // given
        let viewDidLoad = PublishSubject<Void>()
        let output = sut.transform(input: makeInput(viewDidLoad: viewDidLoad.asObservable()))

        let expectation = XCTestExpectation(description: "isLoading becomes false")
        output.isLoading
            .skip(1)
            .filter { !$0 }
            .drive(onNext: { _ in expectation.fulfill() })
            .disposed(by: disposeBag)

        // when
        viewDidLoad.onNext(())

        // then
        wait(for: [expectation], timeout: 2.0)
    }
}

// MARK: - Helpers

private extension MedicationViewModelTests {
    func makeInput(
        viewDidLoad: Observable<Void> = .empty(),
        toggleMedication: Observable<Medication> = .empty(),
        toggleTimeSlot: Observable<MedicationViewModel.TimeSlotToggleRequest> = .empty(),
        deleteMedication: Observable<Medication> = .empty()
    ) -> MedicationViewModel.Input {
        MedicationViewModel.Input(
            viewDidLoad: viewDidLoad,
            toggleMedication: toggleMedication,
            toggleTimeSlot: toggleTimeSlot,
            deleteMedication: deleteMedication
        )
    }

    func makeMedication(name: String) -> Medication {
        let id = UUID()
        return Medication(
            id: id,
            drugName: name,
            dosage: "100mg",
            type: .oral,
            schedule: MedicationSchedule(times: [Date()], startDate: Date(), endDate: nil, medicationID: id),
            isEnabled: true,
            notificationIDs: [],
            createdAt: Date()
        )
    }
}
