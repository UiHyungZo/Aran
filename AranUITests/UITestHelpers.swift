import XCTest

extension XCTestCase {
    func launchUITestApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        _ = app.wait(for: .runningForeground, timeout: 5)
        return app
    }

    func element(_ id: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: id).firstMatch
    }

    @discardableResult
    func waitForElement(
        _ id: String,
        in app: XCUIApplication,
        timeout: TimeInterval = 8,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> XCUIElement {
        let element = element(id, in: app)
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "Missing element: \(id)", file: file, line: line)
        return element
    }

    func tapElement(
        _ id: String,
        in app: XCUIApplication,
        timeout: TimeInterval = 8,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let element = waitForElement(id, in: app, timeout: timeout, file: file, line: line)
        if element.isHittable {
            element.tap()
        } else {
            element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
    }

    func typeText(
        _ text: String,
        into id: String,
        in app: XCUIApplication,
        timeout: TimeInterval = 8,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let element = waitForElement(id, in: app, timeout: timeout, file: file, line: line)
        element.tap()
        element.typeText(text)
    }

    func waitForEnabled(
        _ id: String,
        in app: XCUIApplication,
        timeout: TimeInterval = 8,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let element = waitForElement(id, in: app, timeout: timeout, file: file, line: line)
        let predicate = NSPredicate(format: "enabled == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed, "Element is not enabled: \(id)", file: file, line: line)
    }

    func waitForValue(
        _ id: String,
        in app: XCUIApplication,
        equals value: String,
        timeout: TimeInterval = 8,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let element = waitForElement(id, in: app, timeout: timeout, file: file, line: line)
        let predicate = NSPredicate(format: "value == %@", value)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed, "Element \(id) value is not \(value)", file: file, line: line)
    }

    func tapTab(_ tabID: String, screenID: String, in app: XCUIApplication) {
        tapElement(tabID, in: app)
        waitForElement(screenID, in: app)
    }

    func dismissKeyboard(in app: XCUIApplication) {
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)).tap()
    }

    func registerTestMedication(in app: XCUIApplication) {
        tapTab("tab.medication", screenID: "screen.medication", in: app)
        tapElement("medication.addButton", in: app)
        typeText("프로", into: "drugSearch.searchField", in: app)
        tapElement("drugSearch.result.0", in: app, timeout: 10)
        waitForElement("screen.medicationForm", in: app, timeout: 12)
        waitForElement("medicationForm.drugName", in: app)

        if !element("medicationForm.save", in: app).isEnabled {
            let field = element("medicationForm.drugName", in: app)
            field.tap()
            field.typeText(" ")
            field.typeText(XCUIKeyboardKey.delete.rawValue)
        }
        waitForEnabled("medicationForm.save", in: app)
        tapElement("medicationForm.save", in: app)
        waitForElement("medication.cell.프로게스테론테스트정", in: app, timeout: 10)
    }
}
