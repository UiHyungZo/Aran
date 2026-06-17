@testable import Aran
import XCTest
import AranDomain

final class HospitalVisitUseCaseTests: XCTestCase {
    private var repository: MockHospitalVisitRepository!
    private var sut: HospitalVisitUseCase!

    override func setUp() {
        super.setUp()
        repository = MockHospitalVisitRepository()
        sut = HospitalVisitUseCase(repository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_fetchAll_returnsAllVisits() async throws {
        // given
        repository.visits = [makeVisit(), makeVisit()]

        // when
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.count, 2)
    }

    func test_fetch_specificDate_returnsMatchingVisits() async throws {
        // given
        let target = Calendar.current.startOfDay(for: Date())
        let other = Calendar.current.date(byAdding: .day, value: -1, to: target)!
        repository.visits = [makeVisit(date: target), makeVisit(date: other)]

        // when
        let result = try await sut.fetch(date: target)

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertTrue(Calendar.current.isDate(result.first!.visitDate, inSameDayAs: target))
    }

    func test_save_validVisitTypes_savesSuccessfully() async throws {
        // when
        try await sut.save(visitDate: Date(), visitTypes: ["내원", "채혈"], memo: "메모")

        // then
        XCTAssertEqual(repository.visits.count, 1)
        XCTAssertEqual(repository.visits.first?.visitTypes, ["내원", "채혈"])
    }

    func test_save_emptyVisitTypes_throwsInvalidInput() async {
        // when / then
        do {
            try await sut.save(visitDate: Date(), visitTypes: [], memo: nil)
            XCTFail("빈 visitTypes는 에러를 던져야 한다")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_save_whitespaceOnlyVisitTypes_throwsInvalidInput() async {
        // when / then
        do {
            try await sut.save(visitDate: Date(), visitTypes: ["  ", "\n"], memo: nil)
            XCTFail("공백만 있는 visitTypes는 에러를 던져야 한다")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_update_validVisitTypes_updatesSuccessfully() async throws {
        // given
        let visit = makeVisit(types: ["내원"])
        repository.visits = [visit]
        var updated = visit
        updated.visitTypes = ["초음파"]

        // when
        try await sut.update(updated)

        // then
        XCTAssertEqual(repository.visits.first?.visitTypes, ["초음파"])
    }

    func test_update_emptyVisitTypes_throwsInvalidInput() async {
        // given
        let visit = makeVisit(types: ["내원"])
        repository.visits = [visit]
        var updated = visit
        updated.visitTypes = []

        // when / then
        do {
            try await sut.update(updated)
            XCTFail("빈 visitTypes 업데이트는 에러를 던져야 한다")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_delete_removesVisit() async throws {
        // given
        let visit = makeVisit()
        repository.visits = [visit]

        // when
        try await sut.delete(id: visit.id)

        // then
        XCTAssertTrue(repository.visits.isEmpty)
    }
}

// MARK: - Helpers

private extension HospitalVisitUseCaseTests {
    func makeVisit(date: Date = Date(), types: [String] = ["내원"]) -> HospitalVisit {
        HospitalVisit(id: UUID(), visitDate: date, visitTypes: types, memo: nil)
    }
}
