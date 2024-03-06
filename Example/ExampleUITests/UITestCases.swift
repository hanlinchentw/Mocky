//
//  UITestCases.swift
//  ExampleUITests
//
//  Created by 陳翰霖 on 2024/3/6.
//

import XCTest
import Mocky

enum TAEnvironment {
	case mockLocalData // Only works with targeted UI tests
}

class UITestCases: XCTestCase {
	private var taMockHeaderSender: TAHeaderSender!
	var taEnvironment: TAEnvironment = .mockLocalData
	private var taHeaderSenderPort: UInt16!
	var app = XCUIApplication()

	var launchArguments: [LaunchArgument] {
		var args: [LaunchArgument] = [.uiTesting]
		switch taEnvironment {
		case .mockLocalData:
			args.append(.targetedUITesting)
			args.append(.taLocalMock(port: taHeaderSenderPort))
		}
		return args
	}

	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		configure()
//		taEventReceiver = TAEventReceiver(port: trackingReceiverPort)
//		taEventReceiver?.onReceiveDqdResponse = { [weak self] dqdResponse in
//			self?.validate(dqdResponse: dqdResponse)
//		}
//		taEventReceiver?.start()
		taMockHeaderSender = TAHeaderSender(port: taHeaderSenderPort)

		launchApp()
	}

	func launchApp() {
		let tempArgs = launchArguments
		app.launchArguments += tempArgs.map { $0.rawValue }
		app.launch()
	}

	open func configure() {
		taHeaderSenderPort = UInt16.randomPrivatePort
	}

	func mockFile(_ filename: String, for servicePath: String, headers: [String: String]? = nil) {
		let bundle = Bundle(for: Self.self)
		guard let filePath = bundle.path(forResource: filename, ofType: nil) else {
			XCTFail("\(filename) does not exist")
			return
		}
		let mockFile = LocalMockResponse(filePath: filePath, servicePath: servicePath, responseHeaders: headers)
		let succeed = taMockHeaderSender.send(file: mockFile)
		XCTAssert(succeed, "Mock Local JSON - failed to use \(filename)")
	}
}
