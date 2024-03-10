//
//  ClientConnection.swift
//
//
//  Created by 陳翰霖 on 2024/3/10.
//

import Foundation
import Network

final class ClientConnection {
	let port: UInt16

	struct Item {
		let data: Data
		let workItem: DispatchWorkItem?
	}

	private var itemsToSend: [Item] = []
	private let identifier: String
	private let connection: NWConnection
	private let connectionQueue: DispatchQueue
	private let dataAccessQueue: DispatchQueue

	private var pendingAcknowledgement: [UInt32: DispatchWorkItem] = [:]
	private var steadyIdentifier: UInt32 = 0
	private let pendingAccessQueue: DispatchQueue

	init(
		port: UInt16,
		identifier: String
	) {
		self.port = port
		self.identifier = identifier
		self.connectionQueue = DispatchQueue(label: identifier + ".connection")
		self.dataAccessQueue = DispatchQueue(label: identifier + ".dataAccess")
		self.pendingAccessQueue = DispatchQueue(label: identifier + ".pendingAccess")
		guard let udpPort = NWEndpoint.Port(rawValue: self.port) else { fatalError("Can't create NWEndpoint port") }
		let parameters = NWParameters.udp
		parameters.allowLocalEndpointReuse = true
		self.connection = NWConnection(
			host: .ipv4(.loopback),
			port: udpPort,
			using: parameters
		)
		connection.start(queue: connectionQueue)
		receive(connection: connection)
	}

	private func receive(connection: NWConnection) {
		connection.receiveMessage { [weak self] data, _, _, error in
			guard let self = self else { return }
			if let data = data {
				let identifier = data.withUnsafeBytes { $0.load(as: UInt32.self) }
				self.removePending(identifier: identifier)
			}
			if let error = error {
				print("\(self) error on received message: \(error)")
				return
			}
			self.receive(connection: connection)
		}
	}

	@discardableResult
	func enqueue(dataToSend data: Data, shouldWaitForAcknowledgement: Bool = false) -> Bool {
		let workItem = shouldWaitForAcknowledgement ? DispatchWorkItem(block: {}) : nil
		dataAccessQueue.sync {
			itemsToSend.append(Item(data: data, workItem: workItem))
		}
		sendNext()
		if let workItem = workItem {
			return workItem.wait(timeout: .now() + 10) == .success
		} else {
			return true
		}
	}

	private func enqueuePending(_ workItem: DispatchWorkItem?) -> UInt32 {
		pendingAccessQueue.sync {
			steadyIdentifier += 1
			pendingAcknowledgement[steadyIdentifier] = workItem
			return steadyIdentifier
		}
	}

	private func removePending(identifier: UInt32) {
		pendingAccessQueue.sync {
			if let workItem = pendingAcknowledgement.removeValue(forKey: identifier) {
				DispatchQueue.global().async(execute: workItem)
			}
		}
	}

	private func sendNext() {
		guard let item = getNextItemToSend() else { return }
		let identifier = enqueuePending(item.workItem)
		var data = item.data
		data.insert(contentsOf: withUnsafeBytes(of: identifier, Array.init), at: 0)
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
