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
    private var mockFiles: [String: LocalMockResponse] = [:]

    public func startLocalServer(atPort port: UInt16) {
        server = LocalServer(port: port)
        server?.onMessageReceived = {
            self.handleReceivedMessage($0)
        }
        server?.start()
    }

    public func stop() {
        server?.stop()
    }

    private func handleReceivedMessage(_ data: Data) {
        print(data)
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

    public func mockFile(for servicePath: String) -> LocalMockResponse? {
        accessQueue.sync {
            self.mockFiles[servicePath]
        }
    }
}
