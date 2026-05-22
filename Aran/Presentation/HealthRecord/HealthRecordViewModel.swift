import Foundation
import RxCocoa
import RxSwift

struct TestItemSummary {
    let item: TestItem
    let latestRecord: HealthRecord
    let trend: Double?
}

typealias ExamSection = (title: String, summaries: [TestItemSummary])

final class HealthRecordViewModel {
    struct Input {
        let viewWillAppear: Observable<Void>
        let deleteRecord: Observable<HealthRecord>
    }

    struct Output {
        let sections: Driver<[ExamSection]>
        let isLoading: Driver<Bool>
        let error: Driver<String>
    }

    private let useCase: HealthRecordUseCase
    private let disposeBag = DisposeBag()

    init(useCase: HealthRecordUseCase) {
        self.useCase = useCase
    }

    func transform(input: Input) -> Output {
        let sectionsRelay = BehaviorRelay<[ExamSection]>(value: [])
        let isLoadingRelay = BehaviorRelay<Bool>(value: false)
        let errorRelay = PublishRelay<String>()

        let reload = PublishRelay<Void>()

        Observable.merge(input.viewWillAppear, reload.asObservable())
            .do(onNext: { isLoadingRelay.accept(true) })
            .flatMapLatest { [weak self] _ -> Observable<[ExamSection]> in
                guard let self else { return .empty() }
                return Observable.create { observer in
                    Task {
                        do {
                            let grouped = try await self.useCase.fetchLatestPerItem()
                            let sections = self.buildSections(from: grouped)
                            observer.onNext(sections)
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
            .bind(to: sectionsRelay)
            .disposed(by: disposeBag)

        input.deleteRecord
            .flatMapLatest { [weak self] record -> Observable<Void> in
                guard let self else { return .empty() }
                return Observable.create { observer in
                    Task {
                        do {
                            try await self.useCase.delete(id: record.id)
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
            sections: sectionsRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            error: errorRelay.asDriver(onErrorJustReturn: "")
        )
    }

    private func buildSections(from grouped: [TestItem: [HealthRecord]]) -> [ExamSection] {
        let categories: [(String, [TestItem])] = [
            ("난소 기능 검사", [.fsh, .amh, .afc, .e2, .progesterone, .lh, .beta_hcg]),
            ("유전 / 면역 검사", [.pgt, .chromosomeCouple, .implantation]),
        ]

        var result: [ExamSection] = []
        for (title, items) in categories {
            var summaries: [TestItemSummary] = []
            for item in items {
                guard let records = grouped[item], let latest = records.first else { continue }
                let trend: Double?
                if item.isNumeric, records.count >= 2 {
                    trend = latest.value - records[1].value
                } else {
                    trend = nil
                }
                summaries.append(TestItemSummary(item: item, latestRecord: latest, trend: trend))
            }
            if !summaries.isEmpty {
                result.append((title: title, summaries: summaries))
            }
        }
        return result
    }
}
