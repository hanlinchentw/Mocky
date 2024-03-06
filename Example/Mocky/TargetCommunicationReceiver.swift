// Created on 17.11.20. Copyright © 2020 Foodora. All rights reserved.

import Foundation
import Network

final class TargetCommunicationReceiver {
  let port: UInt16

  var onMessageReceived: ((Data) -> Void)?

  private var listener: NWListener

  private let listenerQueue = DispatchQueue(label: "TargetCommunicationReceiver.listener")
  private let connectionsQueue = DispatchQueue(label: "TargetCommunicationReceiver.connections")

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
        let identifier = data.prefix(MemoryLayout<UInt32>.size)
        data.removeFirst(MemoryLayout<UInt32>.size)
        DispatchQueue.main.async {
          self.onMessageReceived?(data)
        }
        connection.send(content: identifier, completion: .idempotent)
      }
      if let error = error {
        print("\(self) error on received message: \(error)")
        return
      }
      self.receive(connection: connection)
    }
  }
}

extension UInt16 {
  private static let privatePortsRange: ClosedRange<UInt16> = 49152...65535

  public static var randomPrivatePort: UInt16 {
    guard let randomPort = privatePortsRange.randomElement() else {
      fatalError("Can't get random port from \(privatePortsRange)")
    }
    return randomPort
  }
}
