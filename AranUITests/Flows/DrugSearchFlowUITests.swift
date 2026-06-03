import XCTest

final class DrugSearchFlowUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = launchUITestApp()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func test_drugSearchFlow_whenAddingDrugFromDetail_thenMedicationFormIsPrefilled() {
        tapTab("tab.drugInfo", screenID: "screen.drugInfo", in: app)

        typeText("프로", into: "drugSearch.searchField", in: app)
        tapElement("drugSearch.result.0", in: app, timeout: 10)
        tapElement("drugDetail.addMedicationButton", in: app)

        let drugNameField = waitForElement("medicationForm.drugName", in: app)
        let value = drugNameField.value as? String
        XCTAssertTrue(value?.contains("프로게스테론테스트정") == true)
    }
}
