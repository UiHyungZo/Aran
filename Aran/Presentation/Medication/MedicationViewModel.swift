import Foundation
import RxSwift
import RxCocoa

final class MedicationViewModel {
    struct Input {
        let viewDidLoad: Observable<Void>
        let toggleMedication: Observable<Medication>
        let deleteMedication: Observable<Medication>
    }

    struct Output {
        let medications: Driver<[Medication]>
        let isLoading: Driver<Bool>
        let error: Driver<String>
    }

    private let medicationUseCase: MedicationUseCase
    private let disposeBag = DisposeBag()

    init(medicationUseCase: MedicationUseCase) {
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
                    Task {
                        do {
                            let result = try await self.medicationUseCase.fetchAll()
                            observer.onNext(result)
                            observer.onCompleted()
                        } catch {
                            observer.onError(error)
                        }
                    }
                    return Disposables.create()
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
                    Task {
                        do {
                            try await self.medicationUseCase.toggle(medication: medication)
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
            .map { _ in () }
            .bind(to: reload)
            .disposed(by: disposeBag)

        input.deleteMedication
            .flatMapLatest { [weak self] medication -> Observable<Void> in
                guard let self else { return .empty() }
                return Observable.create { observer in
                    Task {
                        do {
                            try await self.medicationUseCase.delete(medication: medication)
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
