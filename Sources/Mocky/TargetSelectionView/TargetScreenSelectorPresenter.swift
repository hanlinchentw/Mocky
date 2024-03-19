// Created on 12.06.23. Copyright © 2023 Delivery Hero SE. All rights reserved.

import Foundation

public protocol TargetScreenSelectorPresenting {
    func onSelectTarget(_ screen: TargetScreen)
    func onViewLoad()
}

public final class TargetScreenSelectorPresenter: TargetScreenSelectorPresenting {
    private weak var view: TargetScreenSelectorView?
    private let router: TargetScreenSelectorRouting
    private let screens: [TargetScreen]

    public init(
        router: TargetScreenSelectorRouting,
        screens: [TargetScreen]
    ) {
        self.router = router
        self.screens = screens
    }

    public func update(view: TargetScreenSelectorView) {
        self.view = view
    }

    public func onSelectTarget(_ screen: TargetScreen) {
        router.open(screen)
    }

    public func onViewLoad() {
        view?.update(with: screens)
    }
}
