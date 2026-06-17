@testable import Aran
import SwiftData
import XCTest
import AranDomain
import AranData

@MainActor
final class HospitalVisitRepositoryTests: XCTestCase {
    private var container: ModelContainer!
    private var sut: HospitalVisitRepository!

    override func setUp() async throws {
        try await super.setUp()
        let schema = Schema([HospitalVisitModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: config)
        sut = HospitalVisitRepository(context: ModelContext(container))
    }

    override func tearDown() async throws {
        sut = nil
        container = nil
        try await super.tearDown()
    }

    func test_save_whenVisitIsValid_thenFetchAllContainsIt() async throws {
        // given
        let visit = makeVisit(types: ["내원", "채혈"])

        // when
        try await sut.save(visit)
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.visitTypes, ["내원", "채혈"])
    }

    func test_fetchByDate_whenVisitsExistForThatDay_thenReturnsOnlyMatchingVisits() async throws {
        // given
        let matching = makeVisit(date: makeDate(day: 1, hour: 9), types: ["초음파"])
        let other = makeVisit(date: makeDate(day: 2, hour: 9), types: ["채혈"])
        try await sut.save(matching)
        try await sut.save(other)

        // when
        let result = try await sut.fetch(date: makeDate(day: 1, hour: 20))

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, matching.id)
    }

    func test_update_whenVisitExists_thenUpdatesStoredValues() async throws {
        // given
        var visit = makeVisit(types: ["내원"], memo: "초기")
        try await sut.save(visit)
        visit.visitTypes = ["내원", "주사"]
        visit.memo = "수정"

        // when
        try await sut.update(visit)
        let result = try await sut.fetch(date: visit.visitDate)

        // then
        XCTAssertEqual(result.first?.visitTypes, ["내원", "주사"])
        XCTAssertEqual(result.first?.memo, "수정")
    }

    func test_delete_whenVisitExists_thenRemovedFromList() async throws {
        // given
        let visit = makeVisit()
        try await sut.save(visit)

        // when
        try await sut.delete(id: visit.id)
        let result = try await sut.fetchAll()

        // then
        XCTAssertFalse(result.contains { $0.id == visit.id })
    }

    func test_fetchAll_whenMultipleVisits_thenSortedByDateDescending() async throws {
        // given
        let earlier = makeVisit(date: makeDate(day: 1), memo: "이전")
        let later = makeVisit(date: makeDate(day: 2), memo: "최근")
        try await sut.save(earlier)
        try await sut.save(later)

        // when
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.map(\.memo), ["최근", "이전"])
    }
}

private extension HospitalVisitRepositoryTests {
    func makeVisit(
        date: Date = Date(),
        types: [String] = ["내원"],
        memo: String? = nil
    ) -> HospitalVisit {
        HospitalVisit(id: UUID(), visitDate: date, visitTypes: types, memo: memo)
    }

    func makeDate(day: Int, hour: Int = 9) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: day, hour: hour)) ?? Date()
    }
}
