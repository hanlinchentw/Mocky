//
//  LocalMockResponseProvider.swift
//
//
//  Created by 陳翰霖 on 2024/3/10.
//

import Foundation

public final class LocalMockResponseProvider {
	public static let shared = LocalMockResponseProvider()
	private let decoder = JSONDecoder()
	private var server: LocalServer?
	private let accessQueue = DispatchQueue(label: "TALocalMockJSONProvider.accessqueue")
	public var mockFiles: [String: LocalMockResponse] = [:]

	public func startLocalServer(atPort port: UInt16) {
		server = LocalServer(port: port)
		server?.onMessageReceived = { self.handleReceivedMessage($0) }
		server?.start()
	}

    public func stop() {
        server?.stop()
    }

	private func handleReceivedMessage(_ data: Data) -> Data? {
		guard let endPoint = String(data: data, encoding: .utf8) else { return  nil }
		guard let mockFile = mockFile(for: endPoint) else { return nil }
		guard let data = try? JSONEncoder().encode(mockFile) else { return nil }
		return data
	}

	public func mockFile(for servicePath: String) -> LocalMockResponse? {
		accessQueue.sync {
			self.mockFiles[servicePath]
		}
	}

	public func sendMock(for servicePath: String, mock: LocalMockResponse) {
		accessQueue.sync {
			self.mockFiles[servicePath] = mock
		}
	}
}
