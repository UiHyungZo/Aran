@testable import Aran
import RxCocoa
import RxSwift
import XCTest

@MainActor
final class HealthRecordViewModelTests: XCTestCase {
    private var useCase: MockHealthRecordUseCase!
    private var sut: HealthRecordViewModel!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        useCase = MockHealthRecordUseCase()
        sut = HealthRecordViewModel(useCase: useCase)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        disposeBag = nil
        sut = nil
        useCase = nil
        super.tearDown()
    }

    func testLoad_whenRecordsExist_buildsSectionsInPRDOrder() async {
        // given
        useCase.stubbedLatestPerItem = [
            HealthRecordType.fsh: [
                makeRecord(type: HealthRecordType.fsh, value: 7.2),
                makeRecord(type: HealthRecordType.fsh, value: 6.4, daysAgo: 10),
            ],
            HealthRecordType.e2: [makeRecord(type: HealthRecordType.e2, value: 214)],
            HealthRecordType.betaHCG: [makeRecord(type: HealthRecordType.betaHCG, value: 312)],
            "비타민D": [makeRecord(type: "비타민D", value: 31, unit: "ng/mL")],
        ]

        let appear = PublishSubject<Void>()
        let output = sut.transform(input: .init(
            viewWillAppear: appear.asObservable(),
            deleteRecord: .empty()
        ))

        let expectation = XCTestExpectation(description: "sections loaded")
        var result: [ExamSection] = []
        output.sections
            .skip(1)
            .drive(onNext: {
                result = $0
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // when
        appear.onNext(())

        // then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(result.map(\.title), ["난소 기능 검사", "호르몬 검사", "임신 확인", "직접 추가"])
        XCTAssertEqual(result.first?.summaries.first?.type, HealthRecordType.fsh)
        XCTAssertEqual(result.first?.summaries.first?.latestRecord.value, 7.2)
        XCTAssertEqual(result.first?.summaries.first?.trend ?? 0, 0.8, accuracy: 0.001)
    }
}

private extension HealthRecordViewModelTests {
    func makeRecord(
        type: String,
        value: Double,
        unit: String = "mIU/mL",
        daysAgo: TimeInterval = 0
    ) -> HealthRecord {
        HealthRecord(
            id: UUID(),
            type: type,
            value: value,
            unit: unit,
            recordDate: Date(timeIntervalSinceNow: -daysAgo * 86_400),
            memo: nil
        )
    }
}
