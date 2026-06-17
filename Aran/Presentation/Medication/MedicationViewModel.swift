import Foundation
import AranDomain
@preconcurrency import RxCocoa
@preconcurrency import RxSwift

@MainActor
final class MedicationViewModel {
    struct TimeSlotToggleRequest {
        let medication: Medication
        let timeSlotID: UUID
    }

    struct Input {
        let viewDidLoad: Observable<Void>
        let toggleMedication: Observable<Medication>
        let toggleTimeSlot: Observable<TimeSlotToggleRequest>
        let deleteMedication: Observable<Medication>
    }

    struct Output {
        let medications: Driver<[Medication]>
        let isLoading: Driver<Bool>
        let error: Driver<String>
    }

    private let medicationUseCase: MedicationUseCaseProtocol
    private let disposeBag = DisposeBag()

    init(medicationUseCase: MedicationUseCaseProtocol) {
        self.medicationUseCase = medicationUseCase
    }

    func transform(input: Input) -> Output {
        let medicationsRelay = BehaviorRelay<[Medication]>(value: [])
        let isLoadingRelay = BehaviorRelay<Bool>(value: false)
        let errorRelay = PublishRelay<String>()

        let reload = PublishRelay<Void>()

        Observable.merge(input.viewDidLoad, reload.asObservable())
            .do(onNext: { isLoadingRelay.accept(true) })
            .flatMapLatest { [weak self] _ -> Observable<[Medication]> in
                guard let self else { return .empty() }
                return Observable.create { observer in
                    let task = Task {
                        do {
                            let result = try await self.medicationUseCase.fetchAll()
                            observer.onNext(result)
                            observer.onCompleted()
                        } catch {
                            observer.onError(error)
                        }
                    }
                    return Disposables.create { task.cancel() }
                }
            }
            .do(onNext: { _ in isLoadingRelay.accept(false) })
            .catch { error in
                isLoadingRelay.accept(false)
                errorRelay.accept((error as? AppError)?.errorDescription ?? error.localizedDescription)
                return .empty()
            }
            .bind(to: medicationsRelay)
            .disposed(by: disposeBag)

        input.toggleMedication
            .flatMapLatest { [weak self] medication -> Observable<Void> in
                guard let self else { return .empty() }
                return Observable.create { observer in
                    let task = Task {
                        do {
                            try await self.medicationUseCase.toggle(medication: medication)
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
            .map { _ in () }
            .bind(to: reload)
            .disposed(by: disposeBag)

        input.toggleTimeSlot
            .flatMapLatest { [weak self] request -> Observable<Void> in
                guard let self else { return .empty() }
                return Observable.create { observer in
                    let task = Task {
                        do {
                            try await self.medicationUseCase.toggleTimeSlot(
                                medication: request.medication,
                                timeSlotID: request.timeSlotID
                            )
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
            .map { _ in () }
            .bind(to: reload)
            .disposed(by: disposeBag)

        input.deleteMedication
            .flatMapLatest { [weak self] medication -> Observable<Void> in
                guard let self else { return .empty() }
                return Observable.create { observer in
                    let task = Task {
                        do {
                            try await self.medicationUseCase.delete(medication: medication)
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
            .map { _ in () }
            .bind(to: reload)
            .disposed(by: disposeBag)

        return Output(
            medications: medicationsRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            error: errorRelay.asDriver(onErrorJustReturn: "")
        )
    }
}
