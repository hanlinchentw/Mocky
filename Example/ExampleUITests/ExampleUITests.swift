//
//  ExampleUITests.swift
//  ExampleUITests
//
//  Created by 陳翰霖 on 2024/3/6.
//

@testable import Example
import MockyXCTestHelpers
import XCTest

final class ExampleUITests: UITestCases {
    func testExample() {
        // Setup mock response for Pokemon API
        mockFile("Mock.json", for: "/api/v2/pokemon")
        app.launch()

        // Verify the mocked data appears in the UI
        XCTAssertTrue(app.staticTexts["Leo"].waitForExistence(timeout: 5))
    }
}

// Mock.json
/*
{
    "count": 1,
    "next": "https://pokeapi.co/api/v2/pokemon/?offset=20&limit=20",
    "previous": null,
    "results": [
        {
            "name": "Leo",
            "url": "https://pokeapi.co/api/v2/pokemon/1/"
        }
    ]
}
*/
