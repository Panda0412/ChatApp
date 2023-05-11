//
//  ProfileScreenUITest.swift
//  ChatAppUITests
//
//  Created by Anastasiia Bugaeva on 11.05.2023.
//

import XCTest

final class ProfileScreenUITest: XCTestCase {

    func testProfileScreen() {
        // Arrange
        let app = XCUIApplication()
        app.launch()
        
        // Act
        app.tabBars["Tab Bar"].buttons["My profile"].tap()
        
        // Assert
        XCTAssertTrue(app.otherElements["Avatar"].exists)
        XCTAssertTrue(app.staticTexts["Nickname"].exists)
        XCTAssertTrue(app.buttons["Edit Profile"].exists)
    }
    
}
