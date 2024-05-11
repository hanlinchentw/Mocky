//
//  RequestInterceptor.swift
//  Example
//
//  Created by 陳翰霖 on 2024/3/10.
//

import Foundation
import Mocky
import os

#if TA_BUILD || DEBUG
    public final class RequestInterceptor: URLProtocol {
        static var mockableDomains: Set<String> = [
            "pokeapi.co",
        ]

        private static let predicate = {
            let predicates = mockableDomains.map {
                let predicateFormat = $0.replacingOccurrences(of: "*", with: ".*")
                return NSPredicate(format: "SELF MATCHES %@", predicateFormat)
            }
            return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        }()

        override public class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url,
                  let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let domain = components.host
            else {
                return false
            }

            return predicate.evaluate(with: domain)
        }

        override public class func canonicalRequest(for request: URLRequest) -> URLRequest { return request }

	public override func startLoading() {
		guard let url = request.url else { return }
		Task {
			guard let mock = await ClientConnectionSender.shared.request(servicePath: url.path) else {
				fail(with: "No mock file found for path \(url.path)")
				return
			}
			let fileURL = URL(fileURLWithPath: mock.filePath)
			guard let jsonData = try? Data(contentsOf: fileURL) else {
				fail(with: "Failed to read from  \(fileURL)")
				return
			}
			let response = HTTPURLResponse(
				url: url,
				statusCode: 200,
				httpVersion: "HTTP/1.1",
				headerFields: mock.responseHeaders
			)
			guard let response = response else { return }

			client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			client?.urlProtocol(self, didLoad: jsonData)
			client?.urlProtocolDidFinishLoading(self)
		}
	}

        override public func stopLoading() {}

        public class func registerProtocol() {
            URLProtocol.registerClass(self)
            let defaultSessionConfiguration = class_getClassMethod(
                URLSessionConfiguration.self,
                #selector(getter: URLSessionConfiguration.default)
            )
            let swizzledDefaultSessionConfiguration = class_getClassMethod(
                URLSessionConfiguration.self,
                #selector(URLSessionConfiguration.swizzledDefaultSessionConfiguration)
            )
            if let defaultSessionConfiguration = defaultSessionConfiguration,
               let swizzledDefaultSessionConfiguration = swizzledDefaultSessionConfiguration
            {
                method_exchangeImplementations(defaultSessionConfiguration, swizzledDefaultSessionConfiguration)
            }

            let ephemeralSessionConfiguration = class_getClassMethod(
                URLSessionConfiguration.self,
                #selector(getter: URLSessionConfiguration.ephemeral)
            )
            let swizzledEphemeralSessionConfiguration = class_getClassMethod(
                URLSessionConfiguration.self,
                #selector(URLSessionConfiguration.swizzledEphemeralSessionConfiguration)
            )
            if let ephemeralSessionConfiguration = ephemeralSessionConfiguration,
               let swizzledEphemeralSessionConfiguration = swizzledEphemeralSessionConfiguration
            {
                method_exchangeImplementations(ephemeralSessionConfiguration, swizzledEphemeralSessionConfiguration)
            }
        }

        private func fail(with errorMessage: String, function: StaticString = #function, line: UInt = #line) {
            let log = OSLog(subsystem: "Example", category: "NetworkInterceptor")
            os_log(
                .error, log: log, "%{public}s:%{public}d\nMocking failed: %{public}s", "\(function)", line, errorMessage
            )
            let error = NSError(domain: "Mocky", code: -1, userInfo: [NSLocalizedDescriptionKey: log])
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    extension URLSessionConfiguration {
        @objc class func swizzledDefaultSessionConfiguration() -> URLSessionConfiguration {
            let configuration = swizzledDefaultSessionConfiguration()
            configuration.protocolClasses?.insert(RequestInterceptor.self, at: 0)
            return configuration
        }

        @objc class func swizzledEphemeralSessionConfiguration() -> URLSessionConfiguration {
            let configuration = swizzledEphemeralSessionConfiguration()
            configuration.protocolClasses?.insert(RequestInterceptor.self, at: 0)
            return configuration
        }
    }
#endif
