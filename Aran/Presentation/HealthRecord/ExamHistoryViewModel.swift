import Foundation
import AranDomain
@preconcurrency import RxCocoa
@preconcurrency import RxSwift

@MainActor
final class ExamHistoryViewModel {
    struct Input {
        let viewWillAppear: Observable<Void>
    }

    struct Output {
        let title: Driver<String>
        let latestSummary: Driver<String>
        let trendText: Driver<String?>
        let records: Driver<[HealthRecord]>
        let isLoading: Driver<Bool>
        let error: Driver<String>
    }

    private let useCase: HealthRecordUseCaseProtocol
    let type: String
    private let disposeBag = DisposeBag()

    init(useCase: HealthRecordUseCaseProtocol, type: String) {
        self.useCase = useCase
        self.type = type
    }

    func transform(input: Input) -> Output {
        let recordsRelay = BehaviorRelay<[HealthRecord]>(value: [])
        let isLoadingRelay = BehaviorRelay<Bool>(value: false)
        let errorRelay = PublishRelay<String>()

        input.viewWillAppear
            .do(onNext: { isLoadingRelay.accept(true) })
            .flatMapLatest { [weak self] _ -> Observable<[HealthRecord]> in
                guard let self else { return .empty() }
                return Observable.create { observer in
                    let task = Task {
                        do {
                            let result = try await self.useCase.fetch(type: self.type)
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
            .bind(to: recordsRelay)
            .disposed(by: disposeBag)

        let titleDriver = Driver.just("\(type) 기록")

        let latestSummary = recordsRelay
            .map { records -> String in
                guard let latest = records.first else { return "-" }
                let value = latest.value
                let formatted = value == value.rounded() ? String(format: "%.0f", value) : String(format: "%.2f", value)
                return "\(formatted) \(latest.unit)"
            }
            .asDriver(onErrorJustReturn: "-")

        let trendText = recordsRelay
            .map { records -> String? in
                guard records.count >= 2 else { return nil }
                let diff = records[0].value - records[1].value
                let formatted = abs(diff) == abs(diff).rounded()
                    ? String(format: "%.0f", abs(diff))
                    : String(format: "%.2f", abs(diff))
                let unit = records[0].unit
                if diff > 0 {
                    return "↑ \(formatted) \(unit)"
                } else if diff < 0 {
                    return "↓ \(formatted) \(unit)"
                } else {
                    return "변화 없음"
                }
            }
            .asDriver(onErrorJustReturn: nil)

        return Output(
            title: titleDriver,
            latestSummary: latestSummary,
            trendText: trendText,
            records: recordsRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            error: errorRelay.asDriver(onErrorJustReturn: "")
        )
    }
}
