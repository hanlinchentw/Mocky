//
//  LocalServer.swift
//
//
//  Created by 陳翰霖 on 2024/3/10.
//

import Foundation
import Network

final class LocalServer {
    let port: UInt16

	var onMessageReceived: ((Data) -> Data?)?

    private var listener: NWListener

    private let listenerQueue = DispatchQueue(label: "LocalServer.listener")
    private let connectionsQueue = DispatchQueue(label: "LocalServer.connections")

	init(port: UInt16) {
		self.port = port
		let parameters = NWParameters.udp
		parameters.allowLocalEndpointReuse = true
		guard let endpointPort = NWEndpoint.Port(rawValue: port) else { fatalError("Can't create NWEndpoint port") }
		parameters.requiredLocalEndpoint = NWEndpoint.hostPort(
			host: .ipv4(.loopback),
			port: endpointPort
		)
		guard let listener = try? NWListener(using: parameters) else {
			fatalError("unable to create NWListener with parameters: \(parameters)")
		}
		self.listener = listener
	}

    func start() {
        listener.newConnectionHandler = { [weak self] connection in
            guard let self = self else { return }
            self.receive(connection: connection)
            connection.start(queue: self.connectionsQueue)
        }
        listener.start(queue: listenerQueue)
    }

    func stop() {
        listener.cancel()
    }

	private func receive(connection: NWConnection) {
		connection.receiveMessage { [weak self] data, _, _, error in
			guard let self = self else { return }
			if var data = data {
				let response = self.onMessageReceived?(data)
				connection.send(content: response, completion: .idempotent)
			}
			if let error = error {
				print("\(self) error on received message: \(error)")
				return
			}
			self.receive(connection: connection)
		}
	}
}
