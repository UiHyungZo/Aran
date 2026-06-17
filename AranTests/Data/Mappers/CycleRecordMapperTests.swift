@testable import Aran
import XCTest
import AranDomain

final class CycleRecordMapperTests: XCTestCase {

    func test_toDomain_whenModelHasStoredFields_thenMapsMainFields() {
        // given
        let id = UUID()
        let date = Date()
        let model = CycleRecordModel(
            id: id,
            cycleNumber: 2,
            date: date,
            retrievalCount: 8,
            fertilizedCount: 5,
            frozenCount: 3,
            diaryEmoji: "🙂",
            diaryText: "기록"
        )

        // when
        let record = CycleRecordMapper.toDomain(model)

        // then
        XCTAssertEqual(record.id, id)
        XCTAssertEqual(record.cycleNumber, 2)
        XCTAssertEqual(record.date, date)
        XCTAssertEqual(record.retrievalCount, 8)
        XCTAssertEqual(record.fertilizedCount, 5)
        XCTAssertEqual(record.frozenCount, 3)
        XCTAssertEqual(record.diary?.emoji, "🙂")
        XCTAssertEqual(record.diary?.content, "기록")
    }

    func test_toModel_whenEntityHasEmbryoRecordsAndEvents_thenPreservesSerializedData() {
        // given
        let cycleId = UUID()
        let transferID = UUID()
        let record = CycleRecord(
            id: cycleId,
            cycleNumber: 3,
            date: Date(),
            retrievalCount: 4,
            fertilizedCount: 3,
            frozenCount: 2,
            embryoRecords: [
                EmbryoRecord(
                    id: UUID(),
                    cycleId: cycleId,
                    stage: .blastocystDay6,
                    simpleGrade: .high,
                    rawGrade: "5AA",
                    isFrozen: true,
                    memo: "동결"
                )
            ],
            events: [.embryoRetrieval(count: 4), .embryoTransfer(transferID: transferID)],
            diary: DiaryEntry(id: UUID(), date: Date(), emoji: "🥲", content: "메모")
        )

        // when
        let model = CycleRecordMapper.toModel(record)
        let restored = CycleRecordMapper.toDomain(model)

        // then
        XCTAssertEqual(restored.embryoRecords.count, 1)
        XCTAssertEqual(restored.embryoRecords.first?.stage, .blastocystDay6)
        XCTAssertEqual(restored.embryoRecords.first?.simpleGrade, .high)
        XCTAssertEqual(restored.embryoRecords.first?.rawGrade, "5AA")
        XCTAssertTrue(restored.embryoRecords.first?.isFrozen ?? false)
        XCTAssertTrue(restored.events.contains {
            guard case let .embryoRetrieval(count) = $0 else { return false }
            return count == 4
        })
        XCTAssertTrue(restored.events.contains {
            guard case let .embryoTransfer(id) = $0 else { return false }
            return id == transferID
        })
        XCTAssertEqual(model.diaryEmoji, "🥲")
        XCTAssertEqual(model.diaryText, "메모")
    }
}
