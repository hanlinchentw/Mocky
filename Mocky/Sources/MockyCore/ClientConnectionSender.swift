//
//  ClientConnectionSender.swift
//
//
//  Created by 陳翰霖 on 2024/3/6.
//

import Foundation

final class ClientConnectionSender {
	static let shared = ClientConnectionSender()
	var sender: ClientConnection?

	public func start(port: UInt16) {
		self.sender = ClientConnection(
			port: port,
			identifier: "ClientConnection"
		)
	}

	init() {}

	public func request(servicePath: String) async -> LocalMockResponse? {
		guard let sender = sender else { return nil }
		return await withCheckedContinuation { continuation in
			sender.enqueue(servicePath: servicePath, completionHandler: { response in
				continuation.resume(returning: response)
			})
		}
	}
}
