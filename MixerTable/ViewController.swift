//
//  ViewController.swift
//  MixerTable
//
//  Created by Kirill Milekhin on 10/09/2023.
//

import UIKit

final class ViewController: UIViewController {
    
    private struct DataModel: Hashable {
        var title: String
        var isSelected: Bool
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(title)
        }

        static func == (lhs: DataModel, rhs: DataModel) -> Bool {
            return lhs.title == rhs.title
        }
    }

    private enum Section: Hashable {
        case main
    }
    
    private var dataModel = Array(0...50).map { DataModel(title: String($0), isSelected: false) }
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        table.delegate = self
        return table
    }()
    
    private lazy var tableViewDataSource: UITableViewDiffableDataSource<Section, DataModel> = {
        UITableViewDiffableDataSource<Section, DataModel>(tableView: tableView) { tableView, indexPath, model in
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            cell.textLabel?.text = model.title
            cell.accessoryType = model.isSelected ? .checkmark : .none
            return cell
        }
    }()
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureInitialDiffableSnapshot()
    }

    private func configureNavigationBar() {
        navigationItem.title = "Task 4"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(didTapShuffleButton))
    }
    
    @objc private func didTapShuffleButton() {
        dataModel.shuffle()
        var snapshot = NSDiffableDataSourceSnapshot<Section, DataModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dataModel, toSection: .main)
        tableViewDataSource.apply(snapshot)
    }
    
    private func configureInitialDiffableSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DataModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dataModel, toSection: .main)
        tableViewDataSource.apply(snapshot, animatingDifferences: false)
    }

}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        cell.accessoryType = cell.accessoryType == .checkmark ? .none : .checkmark
        dataModel[indexPath.row].isSelected.toggle()
        if dataModel[indexPath.row].isSelected {
            dataModel.insert(dataModel.remove(at: indexPath.row), at: 0)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, DataModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dataModel, toSection: .main)
        tableViewDataSource.apply(snapshot)
    }
}
