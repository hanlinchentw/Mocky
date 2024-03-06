// Created on 22.06.23. Copyright © 2023 Delivery Hero SE. All rights reserved.

import Foundation

public struct LocalMockResponse: Codable {
  let filePath: String
  let servicePath: String
  let responseHeaders: [String: String]?

	public init(filePath: String, servicePath: String, responseHeaders: [String : String]?) {
		self.filePath = filePath
		self.servicePath = servicePath
		self.responseHeaders = responseHeaders
	}
}
