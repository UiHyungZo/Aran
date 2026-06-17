import Foundation
import AranDomain
@preconcurrency import RxCocoa
@preconcurrency import RxSwift

@MainActor
final class HealthRecordFormViewModel {
    enum FormMode {
        case add
        case addLocked(type: String)
        case edit(record: HealthRecord)
    }

    struct Input {
        let selectedType: Observable<String>
        let valueText: Observable<String>
        let unitText: Observable<String>
        let date: Observable<Date>
        let memo: Observable<String?>
        let saveTap: Observable<Void>
        let deleteTap: Observable<Void>
    }

    struct Output {
        let isSaveEnabled: Driver<Bool>
        let initialUnitText: Driver<String>
        let saved: Driver<Void>
        let deleted: Driver<Void>
        let error: Driver<String>
    }

    private let useCase: HealthRecordUseCaseProtocol
    private let mode: FormMode
    private let disposeBag = DisposeBag()

    init(useCase: HealthRecordUseCaseProtocol, mode: FormMode = .add) {
        self.useCase = useCase
        self.mode = mode
    }

    func transform(input: Input) -> Output {
        let savedRelay = PublishRelay<Void>()
        let deletedRelay = PublishRelay<Void>()
        let errorRelay = PublishRelay<String>()

        let initialRecord: HealthRecord?
        if case let .edit(record) = mode {
            initialRecord = record
        } else {
            initialRecord = nil
        }

        let initialType: String
        switch mode {
        case .add:
            initialType = HealthRecordType.fsh
        case let .addLocked(type):
            initialType = type
        case let .edit(record):
            initialType = record.type
        }

        let latestType = BehaviorRelay<String>(value: initialType)
        let latestUnit = BehaviorRelay<String>(
            value: initialRecord?.unit ?? HealthRecordType.defaultUnits[initialType] ?? ""
        )
        let latestDate = BehaviorRelay<Date>(value: initialRecord?.recordDate ?? Date())
        let latestMemo = BehaviorRelay<String?>(value: initialRecord?.memo)

        if !mode.isTypeLocked {
            input.selectedType
                .bind(to: latestType)
                .disposed(by: disposeBag)
        }

        input.unitText
            .bind(to: latestUnit)
            .disposed(by: disposeBag)

        input.date
            .bind(to: latestDate)
            .disposed(by: disposeBag)

        input.memo
            .bind(to: latestMemo)
            .disposed(by: disposeBag)

        let parsedValue = input.valueText
            .map { Double($0) }

        let isSaveEnabled = Observable.combineLatest(latestType.asObservable(), parsedValue, input.unitText)
            .map { type, value, unit in
                !type.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    && value != nil
                    && (value ?? 0) > 0
                    && !unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            .asDriver(onErrorJustReturn: false)

        let initialUnitText: Driver<String>
        if case let .addLocked(type) = mode {
            let fallbackUnit = HealthRecordType.defaultUnits[type] ?? ""
            initialUnitText = Observable<String>.create { [weak self] observer in
                let task = Task {
                    do {
                        let records = try await self?.useCase.fetch(type: type) ?? []
                        observer.onNext(records.first?.unit ?? fallbackUnit)
                        observer.onCompleted()
                    } catch {
                        observer.onNext(fallbackUnit)
                        observer.onCompleted()
                    }
                }
                return Disposables.create { task.cancel() }
            }
            .asDriver(onErrorJustReturn: fallbackUnit)
        } else {
            initialUnitText = .empty()
        }

        input.saveTap
            .withLatestFrom(
                Observable.combineLatest(
                    latestType.asObservable(),
                    parsedValue,
                    latestUnit.asObservable(),
                    latestDate.asObservable(),
                    latestMemo.asObservable()
                )
            )
            .flatMapLatest { [weak self] type, value, unit, date, memo -> Observable<Void> in
                guard let self, let value else { return .empty() }
                return Observable.create { observer in
                    let task = Task {
                        do {
                            switch self.mode {
                            case .add, .addLocked(_):
                                try await self.useCase.save(
                                    type: type,
                                    value: value,
                                    unit: unit,
                                    recordDate: date,
                                    memo: memo
                                )
                            case let .edit(record):
                                let updated = HealthRecord(
                                    id: record.id,
                                    type: record.type,
                                    value: value,
                                    unit: unit,
                                    recordDate: date,
                                    memo: memo
                                )
                                try await self.useCase.update(updated)
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
            .bind(to: savedRelay)
            .disposed(by: disposeBag)

        input.deleteTap
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                guard case let .edit(record) = self.mode else { return .empty() }
                return Observable.create { observer in
                    let task = Task {
                        do {
                            try await self.useCase.delete(id: record.id)
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
            .bind(to: deletedRelay)
            .disposed(by: disposeBag)

        return Output(
            isSaveEnabled: isSaveEnabled,
            initialUnitText: initialUnitText,
            saved: savedRelay.asDriver(onErrorJustReturn: ()),
            deleted: deletedRelay.asDriver(onErrorJustReturn: ()),
            error: errorRelay.asDriver(onErrorJustReturn: "")
        )
    }
}

private extension HealthRecordFormViewModel.FormMode {
    var isTypeLocked: Bool {
        switch self {
        case .addLocked(_), .edit(_):
            return true
        case .add:
            return false
        }
    }
}
