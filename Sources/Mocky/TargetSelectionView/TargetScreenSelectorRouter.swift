// Created on 12.06.23. Copyright © 2023 Delivery Hero SE. All rights reserved.

import Foundation

public protocol TargetScreenSelectorRouting {
    func open(_ target: TargetScreen)
}

public final class TargetScreenSelectorRouter: TargetScreenSelectorRouting {
    private weak var view: TargetScreenSelectorView?

    private let screenBuilder: TargetScreenBuilding

    public init(screenBuilder: TargetScreenBuilding) {
        self.screenBuilder = screenBuilder
    }

    public func update(view: TargetScreenSelectorView) {
        self.view = view
    }

    public func open(_ target: TargetScreen) {
        guard let navigationController = view?.navigationController else { return }
        switch target {
        default:
            let viewController = screenBuilder.view(for: target, navigationController: navigationController)
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}
