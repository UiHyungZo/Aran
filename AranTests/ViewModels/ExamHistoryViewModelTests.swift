@testable import Aran
import RxCocoa
import RxSwift
import XCTest

final class ExamHistoryViewModelTests: XCTestCase {
    private var useCase: MockHealthRecordUseCase!
    private var sut: ExamHistoryViewModel!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        useCase = MockHealthRecordUseCase()
        sut = ExamHistoryViewModel(useCase: useCase, type: HealthRecordType.fsh)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        disposeBag = nil
        sut = nil
        useCase = nil
        super.tearDown()
    }

    func testLoad_whenRecordsExist_emitsLatestSummaryAndTrend() {
        // given
        useCase.stubbedByType = [
            makeRecord(value: 8.0),
            makeRecord(value: 6.8, daysAgo: 30),
        ]
        let appear = PublishSubject<Void>()
        let output = sut.transform(input: .init(viewWillAppear: appear.asObservable()))

        let recordsExpectation = XCTestExpectation(description: "records loaded")
        let summaryExpectation = XCTestExpectation(description: "summary loaded")
        let trendExpectation = XCTestExpectation(description: "trend loaded")
        var records: [HealthRecord] = []
        var summary = ""
        var trend: String?

        output.records
            .skip(1)
            .drive(onNext: {
                records = $0
                recordsExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        output.latestSummary
            .skip(1)
            .drive(onNext: {
                summary = $0
                summaryExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        output.trendText
            .skip(1)
            .drive(onNext: {
                trend = $0
                trendExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        // when
        appear.onNext(())

        // then
        wait(for: [recordsExpectation, summaryExpectation, trendExpectation], timeout: 2.0)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(summary, "8 mIU/mL")
        XCTAssertEqual(trend, "↑ 1.20 mIU/mL")
    }
}

private extension ExamHistoryViewModelTests {
    func makeRecord(value: Double, daysAgo: TimeInterval = 0) -> HealthRecord {
        HealthRecord(
            id: UUID(),
            type: HealthRecordType.fsh,
            value: value,
            unit: "mIU/mL",
            recordDate: Date(timeIntervalSinceNow: -daysAgo * 86_400),
            memo: nil
        )
    }
}
