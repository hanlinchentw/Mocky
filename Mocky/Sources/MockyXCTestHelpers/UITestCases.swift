//
//  UITestCases.swift
//  ExampleUITests
//
//  Created by 陳翰霖 on 2024/3/6.
//

import MockyCore
import XCTest

open class UITestCases: XCTestCase {
	public var app = XCUIApplication()

	public override func setUp() {
		super.setUp()

		continueAfterFailure = false

		let localServerPort = UInt16.randomPrivatePort
		LocalMockResponseProvider.shared.startLocalServer(atPort: localServerPort)

		let launchArgs = [LaunchArgument.isTestAutomation, LaunchArgument.localMock(port: localServerPort)]
		app.launchArguments += launchArgs.map { $0.rawValue }
	}

	public func mockFile(_ filename: String, for servicePath: String, headers: [String: String]? = nil) {
		let bundle = Bundle(for: Self.self)
		guard let filePath = bundle.path(forResource: filename, ofType: nil) else {
			XCTFail("\(filename) does not exist")
			return
		}
		let mockFile = LocalMockResponse(filePath: filePath, servicePath: servicePath, responseHeaders: headers)
		LocalMockResponseProvider.shared.sendMock(for: servicePath, mock: mockFile)
	}
}

public extension UInt16 {
    private static let privatePortsRange: ClosedRange<UInt16> = 49152 ... 65535

    public static var randomPrivatePort: UInt16 {
        guard let randomPort = privatePortsRange.randomElement() else {
            fatalError("Can't get random port from \(privatePortsRange)")
        }
        return randomPort
    }
}
