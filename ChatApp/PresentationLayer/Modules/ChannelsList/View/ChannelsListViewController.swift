//
//  ChannelsListViewController.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 05.03.2023.
//

import Combine
import UIKit

private enum Constants {
    static let headerHeight: CGFloat = 36
    static let rowHeight: CGFloat = 76
    static let avatarSize: CGFloat = 32
    static let cellIdentifier = "channelsTableViewCell"
}

class ChannelsListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewIsReady()
        themesService.viewIsReady()
        
        setupNavigationBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        presenter.reloadData()
    }
    
    init(output: ChannelsListViewOutput, themesService: ThemesServiceInput) {
        self.presenter = output
        self.themesService = themesService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    private let presenter: ChannelsListViewOutput
    private let themesService: ThemesServiceInput

    private lazy var channelsTableView = UITableView()
    private lazy var dataSource = ChannelsListDataSource(channelsTableView)

    private let refreshControl = UIRefreshControl()
        
    // MARK: - UI Elements
    
    private lazy var addChannelAlert: UIAlertController = {
        let alert = UIAlertController(title: "New channel", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Channel Name"
            textField.delegate = self
        }
                
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let textField = alert.textFields?.first, let self = self else {
                return
            }
            
            self.presenter.createChannel(textField.text)
            textField.text = ""
        }
        
        createAction.isEnabled = alert.textFields?.first?.text != ""
        
        alert.addAction(dismissAction)
        alert.addAction(createAction)

        return alert
    }()
    
    private lazy var errorAlert: UIAlertController = {
        let alert = UIAlertController(title: "Ooops!", message: "Something went wrong\nIs your internet turned on?", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default)

        alert.addAction(dismissAction)

        return alert
    }()
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = "Back"
        
        navigationItem.setRightBarButton(
            UIBarButtonItem(title: "Add Channel", style: .plain, target: self, action: #selector(addChannelTapped)),
            animated: true
        )
    }
    
    private func setupTableView() {
        channelsTableView.translatesAutoresizingMaskIntoConstraints = false
        channelsTableView.showsVerticalScrollIndicator = false
        
        view.addSubview(channelsTableView)
        
        NSLayoutConstraint.activate([
            channelsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            channelsTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            channelsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            channelsTableView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
        
        channelsTableView.register(ChannelsListTableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        channelsTableView.delegate = self
        
        channelsTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    // MARK: - Helpers
    
    @objc private func addChannelTapped() {
        present(addChannelAlert, animated: true)
    }
    
    @objc private func refreshData() {
        presenter.reloadData()
    }
}

// MARK: - Data source

final class ChannelsListDataSource: UITableViewDiffableDataSource<Int, ChannelItem> {
    init(_ tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? ChannelsListTableViewCell else {
                return UITableViewCell()
            }

            let model = ChannelCellModel(
                nickname: itemIdentifier.name,
                message: itemIdentifier.lastMessage,
                date: itemIdentifier.lastActivity
            )
            
            cell.configure(with: model)
            
            let isLastCellInSection = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
            if isLastCellInSection {
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.frame.width, bottom: 0, right: 0)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 73, bottom: 0, right: 0)
            }
            
            return cell
        }
    }
}

// MARK: - MVP extensions

extension ChannelsListViewController: ChannelsListViewInput {
    func showData(_ channels: [ChannelItem]) {
        var snapshot = dataSource.snapshot()
        
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(channels, toSection: 0)
        
        dataSource.apply(snapshot)
    }
    
    func showAlert() {
        present(errorAlert, animated: true)
    }
    
    func endRefresh() {
        refreshControl.endRefreshing()
    }
}

extension ChannelsListViewController: ThemesServiceOutput {
    func setupTheme(_ theme: UIUserInterfaceStyle) {
        addChannelAlert.overrideUserInterfaceStyle = theme
        errorAlert.overrideUserInterfaceStyle = theme
    }
}

// MARK: - Delegates

extension ChannelsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { Constants.headerHeight }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { Constants.rowHeight }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        presenter.didSelectItem(at: indexPath.row)
    }
}

extension ChannelsListViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        addChannelAlert.actions.first(where: { action in action.title == "Create" })?.isEnabled = textField.text != "" && textField.text != nil
    }
}
