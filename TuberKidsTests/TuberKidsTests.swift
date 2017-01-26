//
//  TuberKidsTests.swift
//  TuberKidsTests
//
//  Created by 成沢淳史 on 10/13/16.
//  Copyright © 2016 naru. All rights reserved.
//

import XCTest
@testable import TuberKids

class TuberKidsTests: XCTestCase {
    let singleton : MovieStorage = MovieStorage()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        singleton.edit()
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
