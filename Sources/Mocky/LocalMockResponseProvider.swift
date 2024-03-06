// Created on 22.06.23. Copyright © 2023 Delivery Hero SE. All rights reserved.

import Foundation

public final class LocalMockResponseProvider {
  public static let shared = LocalMockResponseProvider()
  private let decoder = JSONDecoder()
  private let receiver: TargetCommunicationReceiver
  private let accessQueue = DispatchQueue(label: "TALocalMockJSONProvider.accessqueue")
  private var mockFiles: [String: LocalMockResponse] = [:]

  private init() {
    let portKey = LaunchArgument.Keys.taLocalMock
    let portValue = LaunchArgument.value(
      for: portKey,
      from: ProcessInfo.processInfo.arguments
    )
    guard let value = portValue, let port = UInt16(value) else {
      fatalError("No port for \(portKey) provided")
    }
    self.receiver = TargetCommunicationReceiver(port: port)

    receiver.onMessageReceived = {
      self.handleReceivedMessage($0)
    }
  }

	public func start() {
    receiver.start()
  }

	public func stop() {
    receiver.stop()
  }

  private func handleReceivedMessage(_ data: Data) {
    guard let mockFile = try? decoder.decode(LocalMockResponse.self, from: data) else {
      return
    }
    var servicePath = mockFile.servicePath
    if !servicePath.hasPrefix("/") {
      servicePath = "/\(servicePath)"
    }
    accessQueue.async {
      self.mockFiles[servicePath] = mockFile
    }
  }

  func mockFile(for servicePath: String) -> LocalMockResponse? {
    accessQueue.sync {
      self.mockFiles[servicePath]
    }
  }

  func isMockAvalilable(for servicePath: String) -> Bool {
    let availablePaths = accessQueue.sync {
      self.mockFiles.keys
    }
    return availablePaths.contains(servicePath)
  }
}
