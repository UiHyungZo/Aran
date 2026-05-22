import Foundation
import RxCocoa
import RxSwift

final class MedicationFormViewModel {
    struct Input {
        let drugNameChanged: Observable<String>
        let typeSelected: Observable<MedicationType>
        let dosageChanged: Observable<String>
        let timesChanged: Observable<[Date]>
        let startDateChanged: Observable<Date>
        let isNotificationEnabled: Observable<Bool>
        let saveTapped: Observable<Void>
    }

    struct Output {
        let isSaveEnabled: Driver<Bool>
        let saveCompleted: Driver<Void>
        let error: Driver<String>
    }

    private let medicationUseCase: MedicationUseCase
    private let disposeBag = DisposeBag()

    init(medicationUseCase: MedicationUseCase) {
        self.medicationUseCase = medicationUseCase
    }

    func transform(input: Input) -> Output {
        let saveCompletedRelay = PublishRelay<Void>()
        let errorRelay = PublishRelay<String>()

        let drugName = input.drugNameChanged.startWith("")
        let type = input.typeSelected.startWith(.oral)
        let dosage = input.dosageChanged.startWith("")
        let times = input.timesChanged.startWith([])
        let startDate = input.startDateChanged.startWith(Date())
        let isNotificationEnabled = input.isNotificationEnabled.startWith(false)

        let isSaveEnabled = Observable
            .combineLatest(drugName, dosage) { name, dos in
                !name.trimmingCharacters(in: .whitespaces).isEmpty &&
                    !dos.trimmingCharacters(in: .whitespaces).isEmpty
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        let formState = Observable.combineLatest(
            Observable.combineLatest(drugName, type, dosage),
            Observable.combineLatest(times, startDate, isNotificationEnabled)
        )

        input.saveTapped
            .withLatestFrom(formState)
            .flatMapLatest { [weak self] combined -> Observable<Void> in
                guard let self else { return .empty() }
                let (nameTypeDosage, timesStartNotif) = combined
                let (name, medicationType, dosage) = nameTypeDosage
                let (times, startDate, notificationsEnabled) = timesStartNotif

                let defaultTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: startDate) ?? startDate
                let schedule = MedicationSchedule(
                    times: times.isEmpty ? [defaultTime] : times,
                    startDate: startDate,
                    endDate: nil
                )
                let medication = Medication(
                    id: UUID(),
                    drugName: name.trimmingCharacters(in: .whitespaces),
                    dosage: dosage.trimmingCharacters(in: .whitespaces),
                    type: medicationType,
                    schedule: schedule,
                    isEnabled: notificationsEnabled,
                    notificationIDs: [],
                    createdAt: Date()
                )
                return Observable.create { observer in
                    Task {
                        do {
                            try await self.medicationUseCase.save(medication)
                            observer.onNext(())
                            observer.onCompleted()
                        } catch {
                            observer.onError(error)
                        }
                    }
                    return Disposables.create()
                }
            }
            .catch { error in
                errorRelay.accept((error as? AppError)?.errorDescription ?? error.localizedDescription)
                return .empty()
            }
            .bind(to: saveCompletedRelay)
            .disposed(by: disposeBag)

        return Output(
            isSaveEnabled: isSaveEnabled,
            saveCompleted: saveCompletedRelay.asDriver(onErrorJustReturn: ()),
            error: errorRelay.asDriver(onErrorJustReturn: "")
        )
    }
}
