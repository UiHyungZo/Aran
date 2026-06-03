import XCTest

final class CalendarFlowUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = launchUITestApp()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func test_calendarDiaryFlow_whenSavingDiary_thenSummaryReflectsDiary() {
        waitForElement("screen.calendar", in: app)

        tapElement("calendar.day.today", in: app)
        waitForElement("calendar.summaryPanel", in: app)
        tapElement("calendar.summary.diary", in: app)

        typeText("UITest 감정 일기", into: "calendar.diary.text", in: app)
        dismissKeyboard(in: app)
        waitForEnabled("calendar.diary.save", in: app)
        tapElement("calendar.diary.save", in: app)

        waitForElement("calendar.summaryPanel", in: app)
        XCTAssertTrue(app.staticTexts["UITest 감정 일기"].waitForExistence(timeout: 8))
    }
}
