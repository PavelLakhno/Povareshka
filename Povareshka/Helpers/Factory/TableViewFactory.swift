//
//  TableViewFactory.swift
//  Povareshka
//
//  Created by user on 16.08.2025.
//

import UIKit

enum TableViewType {
    case plain
    case grouped
    case insetGrouped
}

struct TableViewCellConfig {
    let cellClass: AnyClass
    let identifier: String
}

@MainActor
func createTableView(
    type: TableViewType = .plain,
    cellConfigs: [TableViewCellConfig],
    delegate: UITableViewDelegate? = nil,
    dataSource: UITableViewDataSource? = nil,
    backgroundColor: UIColor = .clear,
    isScrollEnabled: Bool = true,
    separatorStyle: UITableViewCell.SeparatorStyle = .none,
    sectionHeaderTopPadding: CGFloat = 0,
    cornerRadius: CGFloat = 0
) -> UITableView {
    let tableView: UITableView
    
    switch type {
    case .plain:
        tableView = UITableView(frame: .zero, style: .plain)
    case .grouped:
        tableView = UITableView(frame: .zero, style: .grouped)
    case .insetGrouped:
        tableView = UITableView(frame: .zero, style: .insetGrouped)
    }
    
    tableView.backgroundColor = backgroundColor
    tableView.isScrollEnabled = isScrollEnabled
    tableView.separatorStyle = separatorStyle
    tableView.sectionHeaderTopPadding = sectionHeaderTopPadding
    tableView.layer.cornerRadius = cornerRadius
    tableView.delegate = delegate
    tableView.dataSource = dataSource
    tableView.translatesAutoresizingMaskIntoConstraints = false
    
    for config in cellConfigs {
        tableView.register(config.cellClass, forCellReuseIdentifier: config.identifier)
    }
    
    return tableView
}
