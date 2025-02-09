//
//  zadanie_04Tests_v2.swift
//  zadanie-04Tests-v2
//
//  Created by Alexander on 09/02/2025.
//

import XCTest
import CoreData

@testable import zadanie_04

final class zadanie_04Tests_v2: XCTestCase {

    var persistenceController: PersistenceController!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        persistenceController = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
