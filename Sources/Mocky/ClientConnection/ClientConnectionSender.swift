//
//  ClientConnectionSender.swift
//
//
//  Created by 陳翰霖 on 2024/3/6.
//

import Foundation

public final class ClientConnectionSender {
    private let sender: ClientConnection?

    public init(port: UInt16) {
        sender = ClientConnection(
            port: port,
            identifier: "ClientConnection"
        )
    }

    @discardableResult
    public func send(file: LocalMockResponse) -> Bool {
        guard
            let data = try? JSONEncoder().encode(file),
            let sender = sender
        else {
            return false
        }
        return sender.enqueue(dataToSend: data, shouldWaitForAcknowledgement: true)
    }
}
