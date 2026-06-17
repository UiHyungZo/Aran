@testable import Aran
import XCTest
import AranDomain

final class MenstrualCycleUseCaseTests: XCTestCase {
    private var repository: MockMenstrualCycleRepository!
    private var sut: MenstrualCycleUseCase!

    override func setUp() {
        super.setUp()
        repository = MockMenstrualCycleRepository()
        sut = MenstrualCycleUseCase(repository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_save_whenCycleDoesNotExist_thenSavesDefaultCycleLength() async throws {
        // given
        let startDate = Date()

        // when
        try await sut.save(startDate: startDate)

        // then
        XCTAssertEqual(repository.cycles.first?.cycleLength, 28)
    }

    func test_save_whenCycleExists_thenUpdatesCycleLength() async throws {
        // given
        let startDate = Date()
        try await sut.save(startDate: startDate, cycleLength: 28)

        // when
        try await sut.save(startDate: startDate, cycleLength: 32)

        // then
        XCTAssertEqual(repository.cycles.count, 1)
        XCTAssertEqual(repository.cycles.first?.cycleLength, 32)
    }

    func test_periodDates_thenReturnsDatesEqualToPeriodLength() {
        // given
        let startDate = Date(timeIntervalSince1970: 0)
        let cycle = MenstrualCycle(id: UUID(), startDate: startDate, cycleLength: 28, periodLength: 5)

        // when
        let result = sut.periodDates(for: cycle)

        // then
        XCTAssertEqual(result.count, 5)
        XCTAssertEqual(result.first, startDate)
    }

    func test_nextPeriodDate_thenReturnsStartDatePlusCycleLength() {
        // given
        let startDate = Date(timeIntervalSince1970: 0)
        let cycle = MenstrualCycle(id: UUID(), startDate: startDate, cycleLength: 28, periodLength: 5)
        let expected = Calendar.current.date(byAdding: .day, value: 28, to: startDate)

        // when
        let result = sut.nextPeriodDate(after: cycle)

        // then
        XCTAssertEqual(result, expected)
    }

    func test_save_whenPeriodLengthOutOfRange_thenThrows() async {
        // given
        let startDate = Date()

        // when / then
        do {
            try await sut.save(startDate: startDate, cycleLength: 28, periodLength: 1)
            XCTFail("범위를 벗어난 생리 기간은 에러를 던져야 한다")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_calculateOvulationDate_whenCycleLengthIs28_thenReturnsStartDatePlus14Days() {
        // given
        let startDate = Date(timeIntervalSince1970: 0)
        let expected = Calendar.current.date(byAdding: .day, value: 14, to: startDate)

        // when
        let result = sut.calculateOvulationDate(startDate: startDate, cycleLength: 28)

        // then
        XCTAssertEqual(result, expected)
    }
}
