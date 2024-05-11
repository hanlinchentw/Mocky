//
//  ClientConnection.swift
//
//
//  Created by 陳翰霖 on 2024/3/10.
//

import Foundation
import Network

typealias MessageReceivedHandler = (LocalMockResponse) -> Void

final class ClientConnection {
    let port: UInt16

	struct Item {
		let request: String
		let handler: MessageReceivedHandler?
	}

    private var itemsToSend: [Item] = []
    private let identifier: String
    private let connection: NWConnection
    private let connectionQueue: DispatchQueue
    private let dataAccessQueue: DispatchQueue

	private var pendingAcknowledgement: [String: MessageReceivedHandler] = [:]
	private let pendingAccessQueue: DispatchQueue

    init(
        port: UInt16,
        identifier: String
    ) {
        self.port = port
        self.identifier = identifier
        connectionQueue = DispatchQueue(label: identifier + ".connection")
        dataAccessQueue = DispatchQueue(label: identifier + ".dataAccess")
        pendingAccessQueue = DispatchQueue(label: identifier + ".pendingAccess")
        guard let udpPort = NWEndpoint.Port(rawValue: self.port) else { fatalError("Can't create NWEndpoint port") }
        let parameters = NWParameters.udp
        parameters.allowLocalEndpointReuse = true
        connection = NWConnection(
            host: .ipv4(.loopback),
            port: udpPort,
            using: parameters
        )
        connection.start(queue: connectionQueue)
        receive(connection: connection)
    }

	private func receive(connection: NWConnection) {
		connection.receiveMessage { [weak self] data, _, _, error in
			print("ClientConnection.\(#function) data=\(data ?? Data())")
			guard let self = self else { return }
			if let data = data {
				guard let response = try? JSONDecoder().decode(LocalMockResponse.self, from: data) else {
					return
				}
				self.removePending(response: response)
			}
			if let error = error {
				print("\(self) error on received message: \(error)")
				return
			}
			self.receive(connection: connection)
		}
	}

	func enqueue(servicePath: String, completionHandler: ((LocalMockResponse) -> Void)?) {
		dataAccessQueue.sync {
			itemsToSend.append(Item(request: servicePath, handler: completionHandler))
		}
		sendNext()
	}

	private func enqueuePending(_ item: Item) {
		pendingAccessQueue.sync {
			pendingAcknowledgement[item.request] = item.handler
		}
	}

	private func removePending(response: LocalMockResponse) {
		pendingAccessQueue.sync {
			if let handler = pendingAcknowledgement.removeValue(forKey: response.servicePath) {
				let workItem = DispatchWorkItem {
					handler(response)
				}
				DispatchQueue.global().async(execute: workItem)
				_ = workItem.wait(timeout: .now() + 10)
			}
		}
	}

	private func sendNext() {
		guard let item = getNextItemToSend() else { return }
		enqueuePending(item)
		var data = item.request.data(using: .utf8)
		connection.send(content: data, completion: .contentProcessed { [weak self] error in
			guard let self = self else { return }
			if let error = error {
				print("\(self.identifier) error on connection send: \(error)")
				return
			}
			self.sendNext()
		})
	}

    private func getNextItemToSend() -> Item? {
        return dataAccessQueue.sync {
            if itemsToSend.isEmpty { return nil }
            return itemsToSend.removeLast()
        }
    }
}
