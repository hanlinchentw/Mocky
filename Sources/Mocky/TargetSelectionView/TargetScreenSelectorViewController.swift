// Created on 12.06.23. Copyright © 2023 Delivery Hero SE. All rights reserved.

import UIKit

public protocol TargetScreenSelectorView: UIViewController {
    func update(with screens: [TargetScreen])
}

public final class TargetScreenSelectorViewController: UITableViewController {
    private var targetScreens: [TargetScreen] = []
    private let presenter: TargetScreenSelectorPresenting

    public init(presenter: TargetScreenSelectorPresenting) {
        self.presenter = presenter
        super.init(style: .grouped)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.accessibilityIdentifier = TargetScreen.selectionTableView
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        presenter.onViewLoad()
    }

    // MARK: - Table view data source

    override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        targetScreens.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let target = targetScreens[indexPath.row].rawValue
        cell.textLabel?.text = target
        cell.accessibilityIdentifier = target
        return cell
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let target = targetScreens[indexPath.row]

        presenter.onSelectTarget(target)
    }
}

extension TargetScreenSelectorViewController: TargetScreenSelectorView {
    public func update(with screens: [TargetScreen]) {
        targetScreens = screens
        tableView.reloadData()
    }
}
