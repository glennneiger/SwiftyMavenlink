//
//  MappableObjectTests.swift
//  SwiftyMavenlink
//
//  Created by Mike Maxwell on 5/20/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import ObjectMapper

class MapableObjectTests: XCTestCase {
    let JsonStringTest: String = "{\"TestProperty\":\"TestValue\"}"
    var mappingResult: TestClass?

    override func setUp() {
        super.setUp()
        mappingResult = Mapper<TestClass>().map(JsonStringTest)
    }

    override func tearDown() {
        super.tearDown()
        mappingResult = nil
    }

    func testSimpleObjectMapping() {
        XCTAssertNotNil(mappingResult)
        XCTAssert(mappingResult?.testProperty == "TestValue", "Property should equal value in JSON")
        XCTAssertNil(mappingResult?.otherProperty)
    }

    func testStringDescription() {
        XCTAssertEqual((mappingResult!.description), JsonStringTest)
    }
}

public class TestClass: MavenlinkObject {
    var testProperty: String?
    var otherProperty: String?

    public override func mapping(map: Map) {
        testProperty <- map["TestProperty"]
    }
}