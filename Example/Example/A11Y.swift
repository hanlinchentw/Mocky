//
//  A11Y.swift
//  Example
//
//  Created by 陳翰霖 on 2024/3/10.
//

import Foundation

public enum A11Y {
	static var tableView: String { #function }

	static func cell(for name: String) -> String {
		#function + name
	}
}
