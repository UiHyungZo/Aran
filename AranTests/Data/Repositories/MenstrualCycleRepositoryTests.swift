@testable import Aran
import SwiftData
import XCTest
import AranDomain

@MainActor
final class MenstrualCycleRepositoryTests: XCTestCase {
    private var container: ModelContainer!
    private var sut: MenstrualCycleRepository!

    override func setUp() async throws {
        try await super.setUp()
        let schema = Schema([MenstrualCycleModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: config)
        sut = MenstrualCycleRepository(context: ModelContext(container))
    }

    override func tearDown() async throws {
        sut = nil
        container = nil
        try await super.tearDown()
    }

    func test_save_whenCycleIsValid_thenFetchAllContainsIt() async throws {
        // given
        let cycle = makeCycle(cycleLength: 30)

        // when
        try await sut.save(cycle)
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.cycleLength, 30)
    }

    func test_fetchByDate_whenCycleExistsForThatDay_thenReturnsIt() async throws {
        // given
        let cycle = makeCycle(startDate: makeDate(day: 1, hour: 8))
        try await sut.save(cycle)

        // when
        let result = try await sut.fetch(date: makeDate(day: 1, hour: 22))

        // then
        XCTAssertEqual(result?.id, cycle.id)
    }

    func test_update_whenCycleExists_thenUpdatesStoredValues() async throws {
        // given
        var cycle = makeCycle(cycleLength: 28, periodLength: 5)
        try await sut.save(cycle)
        cycle.cycleLength = 32
        cycle.periodLength = 6

        // when
        try await sut.update(cycle)
        let result = try await sut.fetch(date: cycle.startDate)

        // then
        XCTAssertEqual(result?.cycleLength, 32)
        XCTAssertEqual(result?.periodLength, 6)
    }

    func test_delete_whenCycleExists_thenRemovedFromList() async throws {
        // given
        let cycle = makeCycle()
        try await sut.save(cycle)

        // when
        try await sut.delete(id: cycle.id)
        let result = try await sut.fetchAll()

        // then
        XCTAssertFalse(result.contains { $0.id == cycle.id })
    }

    func test_fetchAll_whenMultipleCycles_thenSortedByStartDateDescending() async throws {
        // given
        let earlier = makeCycle(startDate: makeDate(day: 1), cycleLength: 28)
        let later = makeCycle(startDate: makeDate(day: 2), cycleLength: 31)
        try await sut.save(earlier)
        try await sut.save(later)

        // when
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.map(\.cycleLength), [31, 28])
    }
}

private extension MenstrualCycleRepositoryTests {
    func makeCycle(
        startDate: Date = Date(),
        cycleLength: Int = 28,
        periodLength: Int = 5
    ) -> MenstrualCycle {
        MenstrualCycle(id: UUID(), startDate: startDate, cycleLength: cycleLength, periodLength: periodLength)
    }

    func makeDate(day: Int, hour: Int = 9) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: day, hour: hour)) ?? Date()
    }
}
