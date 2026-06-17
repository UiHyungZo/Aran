@testable import Aran
import XCTest
import AranDomain

final class DiaryEntryMapperTests: XCTestCase {

    func test_toDomain_whenModelIsValid_thenAllFieldsMapped() {
        // given
        let id = UUID()
        let date = Date()
        let model = DiaryEntryModel(id: id, date: date, emoji: "🙂", content: "좋은 하루")

        // when
        let entry = DiaryEntryMapper.toDomain(model)

        // then
        XCTAssertEqual(entry.id, id)
        XCTAssertEqual(entry.date, date)
        XCTAssertEqual(entry.emoji, "🙂")
        XCTAssertEqual(entry.content, "좋은 하루")
    }

    func test_toModel_whenEntityIsValid_thenAllFieldsMapped() {
        // given
        let id = UUID()
        let date = Date()
        let entry = DiaryEntry(id: id, date: date, emoji: nil, content: "담담한 하루")

        // when
        let model = DiaryEntryMapper.toModel(entry)

        // then
        XCTAssertEqual(model.id, id)
        XCTAssertEqual(model.date, date)
        XCTAssertNil(model.emoji)
        XCTAssertEqual(model.content, "담담한 하루")
    }
}
