// Created on 26.03.20. Copyright © 2020 Foodora. All rights reserved.

public enum LaunchArgument {
  case uiTesting
  case targetedUITesting
  case taLocalMock(port: UInt16)
}

extension LaunchArgument {
  public struct Keys {
    static let uiTesting = "uiTesting"
    static let targetedUITesting = "targetedUITesting"
    static let taLocalMock = "taLocalMock"
  }

	public static func contains(key: String, in launchArguments: [String]) -> Bool {
    return launchArguments.contains(where: { $0.starts(with: key) })
  }

  // for argument "uiTesting123" it will return value "123"
	public static func value(for key: String, from launchArguments: [String]) -> String? {
    guard let argument = launchArguments.first(where: { $0.starts(with: key) }) else {
      return nil
    }
    let value = String(argument.dropFirst(key.count))
		return value.isEmpty ? nil : value
  }
}

extension LaunchArgument: RawRepresentable {
	public typealias RawValue = String

  public init?(rawValue: String) {
    fatalError("Initialization from rawValue not expected")
  }

	public var rawValue: String {
		switch self {
		case .uiTesting:
			return Keys.uiTesting
		case .targetedUITesting:
			return Keys.targetedUITesting
		case let .taLocalMock(port):
			return Keys.taLocalMock + String(port)
		}
  }
}
