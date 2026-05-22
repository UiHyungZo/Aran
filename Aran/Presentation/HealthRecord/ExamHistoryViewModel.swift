import Foundation
import RxCocoa
import RxSwift

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

    private let useCase: HealthRecordUseCase
    let item: TestItem
    private let disposeBag = DisposeBag()

    init(useCase: HealthRecordUseCase, item: TestItem) {
        self.useCase = useCase
        self.item = item
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
                    Task {
                        do {
                            let result = try await self.useCase.fetch(item: self.item)
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
            .bind(to: recordsRelay)
            .disposed(by: disposeBag)

        let titleDriver = Driver.just("\(item.rawValue) 히스토리")

        let latestSummary = recordsRelay
            .map { records -> String in
                guard let latest = records.first else { return "-" }
                if latest.item.isNumeric {
                    let value = latest.value
                    let formatted = value == value.rounded() ? String(format: "%.0f", value) : String(format: "%.2f", value)
                    return "\(formatted) \(latest.testItem.unit)"
                } else if let pgt = latest.pgtResult {
                    return "정상 \(pgt.normal) / 이상 \(pgt.abnormal) / 모자이크 \(pgt.mosaic)"
                } else {
                    return "\(Int(latest.value))개"
                }
            }
            .asDriver(onErrorJustReturn: "-")

        let trendText = recordsRelay
            .map { records -> String? in
                guard records.count >= 2,
                      records[0].testItem.isNumeric else { return nil }
                let diff = records[0].value - records[1].value
                let formatted = abs(diff) == abs(diff).rounded()
                    ? String(format: "%.0f", abs(diff))
                    : String(format: "%.2f", abs(diff))
                let unit = records[0].testItem.unit
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

private extension HealthRecord {
    var item: TestItem {
        testItem
    }
}
