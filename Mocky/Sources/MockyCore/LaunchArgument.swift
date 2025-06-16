//
//  LaunchArgument.swift
//  Example
//
//  Created by 陳翰霖 on 2024/3/10.
//

import Foundation

public enum LaunchArgument: RawRepresentable {
	case isTestAutomation
	case localMock(port: UInt16)
}

public extension LaunchArgument {
	public enum Keys {
		public static let isTestAutomation = "isTestAutomation"
		public static let localMock = "localMock"
	}

	static func contains(key: String, in launchArguments: [String]) -> Bool {
		return launchArguments.contains(where: { $0.starts(with: key) })
	}

	// for argument "uiTesting123" it will return value "123"
	static func value(for key: String, from launchArguments: [String]) -> String? {
		guard let argument = launchArguments.first(where: { $0.starts(with: key) }) else {
			return nil
		}
		let value = String(argument.dropFirst(key.count))
		return value.isEmpty ? nil : value
	}
}

public extension ProcessInfo {
	static var args: [String] { ProcessInfo.processInfo.arguments }

	public static var isTestAutomation: Bool {
		LaunchArgument.contains(key: LaunchArgument.Keys.isTestAutomation, in: args)
	}

	public static var localMockPort: UInt16? {
		guard let value = LaunchArgument.value(for: LaunchArgument.Keys.localMock, from: args) else {
			return nil
		}
		return UInt16(value)
	}
}

// MARK: - RawRepresentable
public extension LaunchArgument {
	public typealias RawValue = String

	public init?(rawValue _: String) {
		fatalError("Initialization from rawValue not expected")
	}

	public var rawValue: String {
		switch self {
		case .isTestAutomation:
			return Keys.isTestAutomation
		case let .localMock(port):
			return Keys.localMock + String(port)
		}
	}
}
