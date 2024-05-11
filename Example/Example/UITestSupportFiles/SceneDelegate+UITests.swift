//
//  SceneDelegate+UITests.swift
//  Example
//
//  Created by 陳翰霖 on 2024/3/10.
//

import Mocky
import UIKit

#if TA_BUILD || DEBUG
extension SceneDelegate {
	func initTargetScreen(scene: UIWindowScene) {
		let router = TargetScreenSelectorRouter(screenBuilder: TargetScreenBuilder())
		let presenter = TargetScreenSelectorPresenter(router: router, screens: [.homeListView])
		let viewController = TargetScreenSelectorViewController(presenter: presenter)
		presenter.update(view: viewController)
		router.update(view: viewController)

		window = UIWindow(windowScene: scene)
		window?.rootViewController = UINavigationController(rootViewController: viewController)
		window?.makeKeyAndVisible()
	}

	func initLocalServer() {
		let portKey = LaunchArgument.Keys.taLocalMock
		let portValue = LaunchArgument.value(
			for: portKey,
			from: ProcessInfo.processInfo.arguments
		)
		guard let value = portValue, let port = UInt16(value) else {
			fatalError("No port for \(portKey) provided")
		}
		ClientConnectionSender.shared.start(port: port)
		RequestInterceptor.registerProtocol()
	}
}

final class TargetScreenBuilder: TargetScreenBuilding {
	func view(
		for target: Mocky.TargetScreen,
		navigationController: UINavigationController
	) -> UIViewController {
		switch target {
		case .homeListView:
			return ViewController()
		default:
			return UIViewController()
		}
	}
}
#endif
