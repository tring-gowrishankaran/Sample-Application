//
//  SampleRssFeedTests.swift
//  SampleRssFeedTests
//
//  Created by Srinivasan on 14/03/16.
//  Copyright © 2016 Tringapps, Inc. All rights reserved.
//

import XCTest
@testable import SampleRssFeed

class SampleRssFeedTests: XCTestCase {
    
    var masterViewCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MasterViewController") as! MasterViewController
    
    override func setUp() {
        
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        masterViewCtrl.managedObjectContext = AppDelegate().managedObjectContext
        XCTAssertNotNil(masterViewCtrl.fetchedResultsController,"Fetch Result View Controller is nil")
        masterViewCtrl.obtainData()
        
        sleep(5)
        XCTAssertTrue(masterViewCtrl.nsxmlParser != nil, "Parser is initialized")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInputFeedSource() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        sleep(20)
        XCTAssertTrue(masterViewCtrl.parsedDataArray.count>0, "Parse Data Array Not Initialized")
        
        print("\(masterViewCtrl.tableView.numberOfRowsInSection(1))")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
}

class MockUpData: NSObject, FeedListDataProviderProtocol {
    
    var parsedDict:[String:String] = Dictionary()
    
    //To track XML elements
    var itemFound = false
    var canParse:Bool = false
    var canIncludeChar:Bool = true
    
    //To append parsed character
    var parsedStr:String?
    
    //To store the obtained data dictionary in array.
    var parsedDataArray : [Dictionary<String, String>] = []
    
    var nsxmlParser:NSXMLParser!

}
