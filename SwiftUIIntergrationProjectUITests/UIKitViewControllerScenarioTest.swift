//
//  UIKitViewControllerScenarioTest.swift
//  SwiftUIIntergrationProjectUITests
//
//  Created by Avinash Kaul on 03/06/24.
//

import XCTest

final class UIKitViewControllerScenarioTest: XCTestCase {

    var app: XCUIApplication!
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
        
    override func tearDown() {
        app = nil
        super.tearDown()
    }
        
    func testWeatherDataDisplay() {
        // Access the horizontal stack view
        sleep(5)
        let addressesStack = app.otherElements["addressesHorizontalStackView"]
        XCTAssertTrue(addressesStack.exists, "Horizontal stack view should be displayed")
            
        // Access the primary address label
        let primaryAddressLabel = app.staticTexts["primaryAddressLabel"]
        XCTAssertTrue(primaryAddressLabel.exists, "Primary address label should be displayed")
            
        // Access the secondary label
        let secondaryLabel = app.staticTexts["secondaryLabel"]
        XCTAssertTrue(secondaryLabel.exists, "Secondary label should be displayed")
            
        // Access the current temperature label
        let currentTemperatureLabel = app.staticTexts["currentTemperatureLabel"]
        XCTAssertTrue(currentTemperatureLabel.exists, "Current temperature label should be displayed")
            
        // Access the weather list view
        let weatherList = app.tables["weatherListView"]
        XCTAssertTrue(weatherList.exists, "Weather list view should be displayed")
            
        // Access a specific weather cell in the list view
        let weatherCell = weatherList.cells.element(boundBy: 0)
        XCTAssertTrue(weatherCell.exists, "Weather cell should be displayed")
            
    }
        
}
