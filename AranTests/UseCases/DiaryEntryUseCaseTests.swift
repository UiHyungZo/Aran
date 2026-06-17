@testable import Aran
import XCTest
import AranDomain

final class DiaryEntryUseCaseTests: XCTestCase {
    private var repository: MockDiaryEntryRepository!
    private var sut: DiaryEntryUseCase!

    override func setUp() {
        super.setUp()
        repository = MockDiaryEntryRepository()
        sut = DiaryEntryUseCase(repository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_fetchAll_returnsAllEntries() async throws {
        // given
        repository.entries = [makeEntry(content: "첫 번째"), makeEntry(content: "두 번째")]

        // when
        let result = try await sut.fetchAll()

        // then
        XCTAssertEqual(result.count, 2)
    }

    func test_fetch_specificDate_returnsMatchingEntry() async throws {
        // given
        let target = Calendar.current.startOfDay(for: Date())
        let other = Calendar.current.date(byAdding: .day, value: -1, to: target)!
        repository.entries = [makeEntry(date: target, content: "오늘"), makeEntry(date: other, content: "어제")]

        // when
        let result = try await sut.fetch(date: target)

        // then
        XCTAssertEqual(result?.content, "오늘")
    }

    func test_save_validContent_savesSuccessfully() async throws {
        // given
        let date = Date()

        // when
        try await sut.save(date: date, emoji: "😊", content: "오늘 기분 좋다")

        // then
        XCTAssertEqual(repository.entries.count, 1)
        XCTAssertEqual(repository.entries.first?.content, "오늘 기분 좋다")
        XCTAssertEqual(repository.entries.first?.emoji, "😊")
    }

    func test_save_emptyContent_throwsInvalidInput() async {
        // when / then
        do {
            try await sut.save(date: Date(), emoji: nil, content: "")
            XCTFail("빈 내용은 에러를 던져야 한다")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_save_whitespaceOnlyContent_throwsInvalidInput() async {
        // when / then
        do {
            try await sut.save(date: Date(), emoji: nil, content: "   \n  ")
            XCTFail("공백만 있는 내용은 에러를 던져야 한다")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_save_contentOver500Chars_throwsInvalidInput() async {
        // given
        let longContent = String(repeating: "가", count: 501)

        // when / then
        do {
            try await sut.save(date: Date(), emoji: nil, content: longContent)
            XCTFail("500자 초과 내용은 에러를 던져야 한다")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_save_existingEntry_updatesInsteadOfCreating() async throws {
        // given
        let date = Date()
        try await sut.save(date: date, emoji: "😊", content: "초기 내용")

        // when
        try await sut.save(date: date, emoji: "😢", content: "수정된 내용")

        // then
        XCTAssertEqual(repository.entries.count, 1)
        XCTAssertEqual(repository.entries.first?.content, "수정된 내용")
        XCTAssertEqual(repository.entries.first?.emoji, "😢")
    }
}

// MARK: - Helpers

private extension DiaryEntryUseCaseTests {
    func makeEntry(date: Date = Date(), content: String) -> DiaryEntry {
        DiaryEntry(id: UUID(), date: date, emoji: nil, content: content)
    }
}
