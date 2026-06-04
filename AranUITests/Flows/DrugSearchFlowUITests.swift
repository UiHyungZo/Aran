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
        waitForElement("drugDetail.container", in: app)
        tapElement("drugDetail.addMedicationButton", in: app)

        let drugNameField = waitForElement("medicationForm.drugName", in: app)
        let value = drugNameField.value as? String
        XCTAssertTrue(value?.contains("프로게스테론테스트정") == true)
    }

    @MainActor
    func test_drugFavoriteFlow_whenFavoriteToggled_thenAppearsInFavoriteList() {
        tapTab("tab.drugInfo", screenID: "screen.drugInfo", in: app)

        // 검색 → 상세 진입
        typeText("프로", into: "drugSearch.searchField", in: app)
        tapElement("drugSearch.result.0", in: app, timeout: 10)
        waitForElement("drugDetail.container", in: app)

        // 즐겨찾기 탭
        tapElement("drugDetail.favoriteButton", in: app)

        // 뒤로가기 (DrugDetailView 네비게이션바 첫 번째 버튼 = Back)
        app.navigationBars["약 상세"].buttons.element(boundBy: 0).tap()

        // 즐겨찾기 목록 진입
        tapElement("drugSearch.favoriteListButton", in: app)

        // 약이 즐겨찾기 목록에 있는지 확인
        waitForElement("favoriteList.item.UITEST-DRUG-001", in: app, timeout: 8)
    }

}
