//
//  TargetScreen.swift
//  Example
//
//  Created by 陳翰霖 on 2024/3/9.
//

import Foundation

public struct TargetScreen: RawRepresentable, Equatable {
    static let selectionTableView = "targetSelectionTableView"

    public var rawValue: String

    public typealias RawValue = String

    public init?(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}
