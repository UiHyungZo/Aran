import Foundation
@preconcurrency import RxCocoa
@preconcurrency import RxSwift

@MainActor
final class MedicationFormViewModel {
    struct Input {
        let drugNameChanged: Observable<String>
        let typeSelected: Observable<MedicationType>
        let componentChanged: Observable<String>
        let dosageChanged: Observable<String>
        let timesChanged: Observable<[Date]>
        let startDateChanged: Observable<Date>
        let endDateChanged: Observable<Date?>
        let isNotificationEnabled: Observable<Bool>
        let saveTapped: Observable<Void>
    }

    struct Output {
        let isSaveEnabled: Driver<Bool>
        let saveCompleted: Driver<Void>
        let error: Driver<String>
        let notificationPermissionDenied: Driver<Void>
    }

    private let medicationUseCase: MedicationUseCaseProtocol
    private let notificationUseCase: MedicationNotificationUseCaseProtocol
    private let initialMedication: Medication?
    private let disposeBag = DisposeBag()

    init(
        medicationUseCase: MedicationUseCaseProtocol,
        notificationUseCase: MedicationNotificationUseCaseProtocol,
        initialMedication: Medication? = nil
    ) {
        self.medicationUseCase = medicationUseCase
        self.notificationUseCase = notificationUseCase
        self.initialMedication = initialMedication
    }

    func transform(input: Input) -> Output {
        let saveCompletedRelay = PublishRelay<Void>()
        let errorRelay = PublishRelay<String>()
        let notificationPermissionDeniedRelay = PublishRelay<Void>()

        input.isNotificationEnabled
            .skip(1)
            .filter { $0 }
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                guard let self else { return .empty() }
                return Observable.create { observer in
                    let task = Task {
                        let status = await self.notificationUseCase.permissionStatus()
                        observer.onNext(status == .denied)
                        observer.onCompleted()
                    }
                    return Disposables.create { task.cancel() }
                }
            }
            .filter { $0 }
            .map { _ in () }
            .bind(to: notificationPermissionDeniedRelay)
            .disposed(by: disposeBag)

        let drugName = input.drugNameChanged.startWith("")
        let type = input.typeSelected.startWith(.oral)
        let component = input.componentChanged.startWith("")
        let dosage = input.dosageChanged.startWith("")
        let times = input.timesChanged.startWith([])
        let startDate = input.startDateChanged.startWith(Date())
        let endDate = input.endDateChanged.startWith(nil)
        let isNotificationEnabled = input.isNotificationEnabled.startWith(false)

        let isSaveEnabled = drugName
            .map { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        let formState = Observable.combineLatest(
            Observable.combineLatest(drugName, type, component, dosage),
            Observable.combineLatest(times, startDate, endDate, isNotificationEnabled)
        )

        input.saveTapped
            .withLatestFrom(formState)
            .flatMapLatest { [weak self] combined -> Observable<Void> in
                guard let self else { return .empty() }
                let (nameTypeComponentDosage, timesStartEndNotif) = combined
                let (name, medicationType, component, dosage) = nameTypeComponentDosage
                let (times, startDate, endDate, notificationsEnabled) = timesStartEndNotif

                let defaultTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: startDate) ?? startDate
                let medicationId = self.initialMedication?.id ?? UUID()
                let slotTimes = times.isEmpty ? [defaultTime] : times
                let timeSlots = self.makeTimeSlots(
                    from: slotTimes,
                    medicationId: medicationId,
                    notificationsEnabled: notificationsEnabled
                )
                let schedule = MedicationSchedule(
                    timeSlots: timeSlots,
                    startDate: startDate,
                    endDate: endDate
                )
                let medication = Medication(
                    id: medicationId,
                    drugName: name.trimmingCharacters(in: .whitespaces),
                    dosage: dosage.trimmingCharacters(in: .whitespaces),
                    component: component.trimmingCharacters(in: .whitespaces),
                    type: medicationType,
                    schedule: schedule,
                    isEnabled: notificationsEnabled,
                    notificationIDs: self.initialMedication?.notificationIDs ?? [],
                    createdAt: self.initialMedication?.createdAt ?? Date()
                )
                return Observable.create { observer in
                    let task = Task {
                        do {
                            if self.initialMedication == nil {
                                try await self.medicationUseCase.save(medication)
                            } else {
                                try await self.medicationUseCase.update(medication)
                            }
                            observer.onNext(())
                            observer.onCompleted()
                        } catch {
                            observer.onError(error)
                        }
                    }
                    return Disposables.create { task.cancel() }
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
            error: errorRelay.asDriver(onErrorJustReturn: ""),
            notificationPermissionDenied: notificationPermissionDeniedRelay.asDriver(onErrorJustReturn: ())
        )
    }

    private func makeTimeSlots(
        from slotTimes: [Date],
        medicationId: UUID,
        notificationsEnabled: Bool
    ) -> [MedicationTimeSlot] {
        var reusableSlots = initialMedication?.schedule.sortedTimeSlots ?? []
        return slotTimes.map { time in
            let id = reuseSlotID(for: time, from: &reusableSlots) ?? UUID()
            return MedicationTimeSlot(
                id: id,
                time: time,
                isEnabled: notificationsEnabled,
                medicationID: medicationId
            )
        }
    }

    private func reuseSlotID(for time: Date, from reusableSlots: inout [MedicationTimeSlot]) -> UUID? {
        guard let index = reusableSlots.firstIndex(where: { isSameClockTime($0.time, time) }) else {
            return nil
        }
        return reusableSlots.remove(at: index).id
    }

    private func isSameClockTime(_ lhs: Date, _ rhs: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.hour, from: lhs) == calendar.component(.hour, from: rhs)
            && calendar.component(.minute, from: lhs) == calendar.component(.minute, from: rhs)
    }
}
