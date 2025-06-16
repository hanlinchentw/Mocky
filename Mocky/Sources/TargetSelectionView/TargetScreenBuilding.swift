//
//  TargetScreenBuilding.swift
//
//
//  Created by 陳翰霖 on 2024/3/10.
//

import UIKit

public protocol TargetScreenBuilding {
    func view(
        for target: TargetScreen,
        navigationController: UINavigationController
    ) -> UIViewController
}
