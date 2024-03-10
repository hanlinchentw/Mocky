//
//  LaunchArgument.swift
//  Example
//
//  Created by 陳翰霖 on 2024/3/10.
//

import Foundation

enum LaunchArgument {
	case taLocalMock(port: UInt16)
}

extension LaunchArgument {
	struct Keys {
		static let taLocalMock = "taLocalMock"
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

extension LaunchArgument: RawRepresentable {
	typealias RawValue = String

	init?(rawValue: String) {
		fatalError("Initialization from rawValue not expected")
	}

	var rawValue: String {
		switch self {
		case let .taLocalMock(port):
			return Keys.taLocalMock + String(port)
		}
	}
}
