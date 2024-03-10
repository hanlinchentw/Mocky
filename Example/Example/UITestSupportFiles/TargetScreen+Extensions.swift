//
//  TargetScreen+Extensions.swift
//  Example
//
//  Created by 陳翰霖 on 2024/3/10.
//

import UIKit
import Mocky

#if TA_BUILD || DEBUG
extension TargetScreen {
	static var homeListView: TargetScreen {
		TargetScreen(rawValue: "view")!
	}
}
#endif
