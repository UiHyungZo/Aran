import XCTest

final class HealthRecordFlowUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = launchUITestApp()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func test_healthRecordFlow_whenSavingTwoValues_thenLatestValueAndTrendAreShown() {
        tapTab("tab.exam", screenID: "screen.exam", in: app)
        saveFSHValue("8.2")
        waitForElement("exam.cell.FSH", in: app, timeout: 10)

        tapElement("exam.addButton", in: app)
        typeText("9.2", into: "healthForm.value", in: app)
        if !element("healthForm.save", in: app).isEnabled {
            typeText(" ", into: "healthForm.unit", in: app)
        }
        dismissKeyboard(in: app)
        waitForEnabled("healthForm.save", in: app)
        tapElement("healthForm.save", in: app)

        waitForElement("exam.cell.FSH", in: app, timeout: 10)
        XCTAssertTrue(element("exam.cell.FSH.trend", in: app).waitForExistence(timeout: 8))
    }

    private func saveFSHValue(_ value: String) {
        tapElement("exam.addButton", in: app)
        typeText(value, into: "healthForm.value", in: app)
        if !element("healthForm.save", in: app).isEnabled {
            typeText(" ", into: "healthForm.unit", in: app)
        }
        dismissKeyboard(in: app)
        waitForEnabled("healthForm.save", in: app)
        tapElement("healthForm.save", in: app)
    }
}
