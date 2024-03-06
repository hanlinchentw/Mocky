//
//  NSError+Extensions.swift
//  
//
//  Created by 陳翰霖 on 2024/3/6.
//

import Foundation

extension NSError {
	convenience init(text: String) {
		self.init(domain: "Volo", code: -1, userInfo: [NSLocalizedDescriptionKey: text])
	}

	func add(tags: [String: Any]) -> NSError {
		let domain = self.domain
		let code = self.code
		var userInfo: [String: Any] = self.userInfo
		for (key, value) in tags {
			userInfo.updateValue(value, forKey: key)
		}
		return NSError(
			domain: domain,
			code: code,
			userInfo: userInfo
		)
	}
}
