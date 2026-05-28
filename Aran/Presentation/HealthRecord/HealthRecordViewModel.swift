import Foundation
import RxCocoa
import RxSwift

struct HealthRecordSummary {
    let type: String
    let latestRecord: HealthRecord
    let trend: Double?
}

typealias ExamSection = (title: String, summaries: [HealthRecordSummary])

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

    private let useCase: HealthRecordUseCaseProtocol
    private let disposeBag = DisposeBag()

    init(useCase: HealthRecordUseCaseProtocol) {
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

    private func buildSections(from grouped: [String: [HealthRecord]]) -> [ExamSection] {
        let categories: [(String, [String])] = [
            ("난소 기능 검사", [HealthRecordType.fsh, HealthRecordType.amh, HealthRecordType.afc]),
            ("호르몬 검사", [HealthRecordType.e2, HealthRecordType.p4, HealthRecordType.lh]),
            ("임신 확인", [HealthRecordType.betaHCG]),
        ]

        var result: [ExamSection] = []
        var displayedTypes = Set<String>()
        for (title, items) in categories {
            var summaries: [HealthRecordSummary] = []
            for type in items {
                guard let records = grouped[type], let latest = records.first else { continue }
                let trend = records.count >= 2 ? latest.value - records[1].value : nil
                summaries.append(HealthRecordSummary(type: type, latestRecord: latest, trend: trend))
                displayedTypes.insert(type)
            }
            if !summaries.isEmpty {
                result.append((title: title, summaries: summaries))
            }
        }
        let customSummaries = grouped.keys
            .filter { !displayedTypes.contains($0) && !HealthRecordType.defaults.contains($0) }
            .sorted()
            .compactMap { type -> HealthRecordSummary? in
                guard let records = grouped[type], let latest = records.first else { return nil }
                let trend = records.count >= 2 ? latest.value - records[1].value : nil
                return HealthRecordSummary(type: type, latestRecord: latest, trend: trend)
            }
        if !customSummaries.isEmpty {
            result.append((title: "직접 추가", summaries: customSummaries))
        }
        return result
    }
}
