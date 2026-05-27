@testable import Aran
import XCTest

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
