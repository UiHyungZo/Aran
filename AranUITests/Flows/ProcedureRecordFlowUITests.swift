import XCTest

final class ProcedureRecordFlowUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = launchUITestApp()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func test_procedureRecordFlow_whenSavingCycleRecord_thenCycleCardAppears() {
        tapTab("tab.procedureRecord", screenID: "screen.procedureRecord", in: app)
        tapElement("procedure.empty.addButton", in: app)

        tapElement("procedureForm.retrieval.increment", in: app)
        tapElement("procedureForm.fertilized.increment", in: app)
        tapElement("procedureForm.frozen.increment", in: app)

        waitForEnabled("procedureForm.save", in: app)
        tapElement("procedureForm.save", in: app)

        waitForElement("procedure.cycle.1", in: app, timeout: 10)
        XCTAssertTrue(app.staticTexts["1차 채취"].waitForExistence(timeout: 8))
    }
}
