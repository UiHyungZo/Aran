import XCTest

final class MedicationFlowUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = launchUITestApp()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func test_medicationRegisterFlow_whenSavingSearchResult_thenListAndEditFormOpen() {
        registerTestMedication(in: app)

        tapElement("medication.cell.프로게스테론테스트정", in: app)

        waitForElement("medicationForm.drugName", in: app)
        XCTAssertTrue(app.navigationBars["약 수정"].waitForExistence(timeout: 8))
    }

    @MainActor
    func test_medicationLogFlow_whenTappingCalendarMedication_thenTakenStateChanges() {
        registerTestMedication(in: app)

        tapTab("tab.calendar", screenID: "screen.calendar", in: app)
        tapElement("calendar.day.today", in: app)
        waitForElement("calendar.summaryPanel", in: app)

        let logID = "calendar.medicationLog.0.0"
        waitForValue(logID, in: app, equals: "notTaken")
        tapElement(logID, in: app)
        waitForValue(logID, in: app, equals: "taken")
    }
}
