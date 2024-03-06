//
//  File.swift
//  
//
//  Created by 陳翰霖 on 2024/3/6.
//

import Foundation

public final class TAHeaderSender {
	private let sender: TargetCommunicationSender?

	public init(port: UInt16) {
		self.sender = TargetCommunicationSender(
			port: port,
			identifier: "TAHeader"
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
