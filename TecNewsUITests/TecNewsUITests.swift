//
//  TecNewsUITests.swift
//  TecNewsUITests
//
//  Created by Bruno Lemgruber on 14/03/2018.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import XCTest

class TecNewsUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSource() {
        let app = XCUIApplication()
        
        snapshot("Source")
        
        let cell = app.tables.cells.element(boundBy: 0)
        expectation(for: NSPredicate(format: "hittable == true"), evaluatedWith: cell, handler: nil)
        waitForExpectations(timeout: 10.0, handler: nil)
        cell.swipeUp()
        cell.tap()
        
    }
    
    func testArticle(){
        let app = XCUIApplication()
        
        let cell =  app.tables.cells.element(boundBy: 0)
        expectation(for: NSPredicate(format: "hittable == true"), evaluatedWith: cell, handler: nil)
        waitForExpectations(timeout: 10.0, handler: nil)
        cell.tap()
        
        snapshot("Article")
        
        let cellArticle =  app.tables.cells.element(boundBy: 0)
        expectation(for: NSPredicate(format: "hittable == true"), evaluatedWith: cellArticle, handler: nil)
        waitForExpectations(timeout: 10.0, handler: nil)
        cellArticle.swipeUp()
        
    }
    
    func testShare(){
        let app = XCUIApplication()
        
        let cell =  app.tables.cells.element(boundBy: 0)
        expectation(for: NSPredicate(format: "hittable == true"), evaluatedWith: cell, handler: nil)
        waitForExpectations(timeout: 10.0, handler: nil)
        cell.tap()
        
        let cellArticle =  app.tables.cells.element(boundBy: 0)
        expectation(for: NSPredicate(format: "hittable == true"), evaluatedWith: cellArticle, handler: nil)
        waitForExpectations(timeout: 10.0, handler: nil)
        
        cellArticle.swipeLeft()

        snapshot("Share")
        
        cellArticle.buttons["share"].tap()
        
    }
    
}
