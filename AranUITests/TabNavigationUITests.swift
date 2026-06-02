//
//  TabNavigationUITests.swift
//  AranUITests
//
//  앱 실행 및 5개 탭 간 네비게이션을 검증하는 UITest.
//

import XCTest

final class TabNavigationUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helpers

    private func tab(_ id: String) -> XCUIElement {
        app.buttons[id]
    }

    @discardableResult
    private func waitForScreen(_ id: String, timeout: TimeInterval = 5) -> Bool {
        app.otherElements[id].waitForExistence(timeout: timeout)
    }

    // MARK: - Tests

    @MainActor
    func test_앱실행시_캘린더탭이_기본화면이다() {
        // given - 앱이 실행됨 (setUp)

        // when - 별도 조작 없음

        // then - 캘린더 화면이 기본으로 표시된다
        XCTAssertTrue(waitForScreen("screen.calendar"))
    }

    @MainActor
    func test_약주사탭_전환() {
        // given - 캘린더 화면이 표시됨
        XCTAssertTrue(waitForScreen("screen.calendar"))

        // when - 약/주사 탭을 탭한다
        tab("tab.medication").tap()

        // then - 약/주사 화면으로 진입한다
        XCTAssertTrue(waitForScreen("screen.medication"))
    }

    @MainActor
    func test_검사탭_전환() {
        // given - 캘린더 화면이 표시됨
        XCTAssertTrue(waitForScreen("screen.calendar"))

        // when - 검사 탭을 탭한다
        tab("tab.exam").tap()

        // then - 검사 화면으로 진입한다
        XCTAssertTrue(waitForScreen("screen.exam"))
    }

    @MainActor
    func test_시술기록탭_전환() {
        // given - 캘린더 화면이 표시됨
        XCTAssertTrue(waitForScreen("screen.calendar"))

        // when - 시술 기록 탭을 탭한다
        tab("tab.procedureRecord").tap()

        // then - 시술 기록 화면으로 진입한다
        XCTAssertTrue(waitForScreen("screen.procedureRecord"))
    }

    @MainActor
    func test_약정보탭_전환() {
        // given - 캘린더 화면이 표시됨
        XCTAssertTrue(waitForScreen("screen.calendar"))

        // when - 약 정보 탭을 탭한다
        tab("tab.drugInfo").tap()

        // then - 약 정보 화면으로 진입한다
        XCTAssertTrue(waitForScreen("screen.drugInfo"))
    }

    @MainActor
    func test_모든탭_순회후_캘린더로_복귀() {
        // given - 캘린더 화면이 표시됨
        XCTAssertTrue(waitForScreen("screen.calendar"))

        // when - 모든 탭을 순차적으로 전환한다
        let order: [(tab: String, screen: String)] = [
            ("tab.medication", "screen.medication"),
            ("tab.exam", "screen.exam"),
            ("tab.procedureRecord", "screen.procedureRecord"),
            ("tab.drugInfo", "screen.drugInfo"),
            ("tab.calendar", "screen.calendar"),
        ]

        // then - 각 탭 전환 시 해당 화면으로 진입한다
        for step in order {
            tab(step.tab).tap()
            XCTAssertTrue(waitForScreen(step.screen), "\(step.tab) 전환 후 \(step.screen) 진입 실패")
        }
    }
}
