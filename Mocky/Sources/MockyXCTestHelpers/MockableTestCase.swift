//
//  MockableTestCase.swift
//  ExampleUITests
//
//  Created by 陳翰霖 on 2024/3/6.
//

import MockyCore
import XCTest

open class MockableTestCase: XCTestCase {
	public var app = XCUIApplication()

    open func configure() {}

    open override func setUp() {
		super.setUp()
		continueAfterFailure = false
        configure()
        let localServerPort = MockableTestCase.randomPrivatePort
        LocalMockResponseProvider.shared.startLocalServer(atPort: localServerPort)

		let launchArgs = [LaunchArgument.isTestAutomation, LaunchArgument.localMock(port: localServerPort)]
		app.launchArguments += launchArgs.map { $0.rawValue }
	}

	public func mockResponse(use filename: String, for servicePath: String, headers: [String: String]? = nil) {
		let bundle = Bundle(for: Self.self)
		guard let filePath = bundle.path(forResource: filename, ofType: nil) else {
			XCTFail("\(filename) does not exist")
			return
		}
		let mockFile = LocalMockResponse(filePath: filePath, servicePath: servicePath, responseHeaders: headers)
		LocalMockResponseProvider.shared.sendMock(for: servicePath, mock: mockFile)
	}
}

private extension MockableTestCase {
    static var randomPrivatePort: UInt16 {
        let range: ClosedRange<UInt16> = (60000 ... 65535)
        guard let randomPort = range.randomElement() else {
            fatalError("Can't get random port from \(range)")
        }
        return randomPort
    }
}
