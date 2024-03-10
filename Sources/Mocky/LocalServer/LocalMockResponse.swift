//
//  LocalMockResponse.swift
//  
//
//  Created by 陳翰霖 on 2024/3/10.
//

import Foundation

public struct LocalMockResponse: Codable {
	public let filePath: String
	public let servicePath: String
	public let responseHeaders: [String: String]?

	public init(filePath: String, servicePath: String, responseHeaders: [String : String]?) {
		self.filePath = filePath
		self.servicePath = servicePath
		self.responseHeaders = responseHeaders
	}
}
