//
//  UITestCases.swift
//  ExampleUITests
//
//  Created by 陳翰霖 on 2024/3/6.
//

import Mocky
import XCTest

class UITestCases: XCTestCase {
    private var clientConnectionSender: ClientConnectionSender!
    var app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let localServerPort = UInt16.randomPrivatePort
        clientConnectionSender = ClientConnectionSender(port: localServerPort)
        app.launchArguments += [LaunchArgument.taLocalMock(port: localServerPort)].map { $0.rawValue }
        app.launch()
    }

    func mockFile(_ filename: String, for servicePath: String, headers: [String: String]? = nil) {
        let bundle = Bundle(for: Self.self)
        guard let filePath = bundle.path(forResource: filename, ofType: nil) else {
            XCTFail("\(filename) does not exist")
            return
        }
        let mockFile = LocalMockResponse(filePath: filePath, servicePath: servicePath, responseHeaders: headers)
        let succeed = clientConnectionSender.send(file: mockFile)
        XCTAssert(succeed, "Mock Local JSON - failed to use \(filename)")
    }
}

extension UITestCases {
    func open(_ targetScreen: TargetScreen) throws {
        try targetScreen.open(in: app)
    }
}

public extension TargetScreen {
    func open(in application: XCUIApplication) throws {
        let cell = application.cells[rawValue]
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
        cell.tap()
    }
}

extension UInt16 {
    private static let privatePortsRange: ClosedRange<UInt16> = 49152 ... 65535

    public static var randomPrivatePort: UInt16 {
        guard let randomPort = privatePortsRange.randomElement() else {
            fatalError("Can't get random port from \(privatePortsRange)")
        }
        return randomPort
    }
}
