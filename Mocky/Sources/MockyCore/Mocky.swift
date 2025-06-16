// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public enum Mocky {
	public static func start(domains: Set<String>) {
		guard let port = ProcessInfo.localMockPort else {
			fatalError("No port provided")
		}
		enable(port: port, domains: domains)
	}

	/// Call this once at app start-up **before** any `URLSession` is created.
	static func enable(
		port: UInt16,
		domains: Set<String>
	) {
		RequestInterceptor.configure(domains: domains)
		RequestInterceptor.start(port: port)
	}

	public func updateDomains(_ domains: Set<String>) {
		RequestInterceptor.configure(domains: domains)
	}
}
