import Foundation
import RxCocoa
import RxSwift

final class PGTFormViewModel {
    struct Input {
        let selectedItem: Observable<TestItem>
        let normalCount: Observable<Int>
        let abnormalCount: Observable<Int>
        let mosaicCount: Observable<Int>
        let date: Observable<Date>
        let note: Observable<String?>
        let saveTap: Observable<Void>
    }

    struct Output {
        let isSaveEnabled: Driver<Bool>
        let saved: Driver<Void>
        let error: Driver<String>
    }

    private let useCase: HealthRecordUseCase
    private let disposeBag = DisposeBag()

    init(useCase: HealthRecordUseCase) {
        self.useCase = useCase
    }

    func transform(input: Input) -> Output {
        let savedRelay = PublishRelay<Void>()
        let errorRelay = PublishRelay<String>()

        let latestItem = BehaviorRelay<TestItem>(value: .pgt)
        let latestDate = BehaviorRelay<Date>(value: Date())
        let latestNote = BehaviorRelay<String?>(value: nil)

        input.selectedItem
            .bind(to: latestItem)
            .disposed(by: disposeBag)

        input.date
            .bind(to: latestDate)
            .disposed(by: disposeBag)

        input.note
            .bind(to: latestNote)
            .disposed(by: disposeBag)

        let totalCount = Observable.combineLatest(
            input.normalCount,
            input.abnormalCount,
            input.mosaicCount
        ) { $0 + $1 + $2 }

        let isSaveEnabled = totalCount
            .map { $0 > 0 }
            .asDriver(onErrorJustReturn: false)

        input.saveTap
            .withLatestFrom(
                Observable.combineLatest(
                    latestItem.asObservable(),
                    input.normalCount,
                    input.abnormalCount,
                    input.mosaicCount,
                    latestDate.asObservable(),
                    latestNote.asObservable()
                )
            )
            .flatMapLatest { [weak self] item, normal, abnormal, mosaic, date, note -> Observable<Void> in
                guard let self else { return .empty() }
                let result = PGTResult(normal: normal, abnormal: abnormal, mosaic: mosaic)
                return Observable.create { observer in
                    Task {
                        do {
                            try await self.useCase.savePGT(item: item, result: result, date: date, note: note)
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
            .bind(to: savedRelay)
            .disposed(by: disposeBag)

        return Output(
            isSaveEnabled: isSaveEnabled,
            saved: savedRelay.asDriver(onErrorJustReturn: ()),
            error: errorRelay.asDriver(onErrorJustReturn: "")
        )
    }
}
