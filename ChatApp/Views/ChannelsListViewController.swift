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
        
        fetchChannels()
        
        setupNavigationBar()
        setupTableView()
        setupDataSource(with: [])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        setupTheme()
    }

    // MARK: - Properties
    
    var currentTheme: UIUserInterfaceStyle = .light
    
    private lazy var channelsTableView = UITableView()
    private lazy var dataSource = ChannelsListDataSource(channelsTableView)
    
    private let chatService = ChannelService()
    private let refreshControl = UIRefreshControl()

    private var userDataRequest: Cancellable?
        
    // MARK: - UI Elements
    
    lazy var addChannelAlert: UIAlertController = {
        let alert = UIAlertController(title: "New channel", message: "", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
        let createAction = UIAlertAction(title: "Create", style: .default)

        alert.addAction(dismissAction)
        alert.addAction(createAction)

        return alert
    }()
    
    // MARK: - Setup
    
    private func setupTheme() {
        addChannelAlert.overrideUserInterfaceStyle = currentTheme
    }
    
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
        refreshControl.addTarget(self, action: #selector(fetchChannels), for: .valueChanged)
    }
    
    private func setupDataSource(with channels: [ChannelItem]) {
        var snapshot = dataSource.snapshot()
                
        snapshot.deleteAllItems()
        snapshot.appendSections(ChannelSections.allCases)
        snapshot.appendItems(channels, toSection: .all)
        
        dataSource.apply(snapshot)
    }
    
    // MARK: - Helpers
    
    @objc private func fetchChannels() {
        chatService.getChannels { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let channels):
                self.setupDataSource(with: channels)
            case .failure(let error):
                print("Error", error)
            }
            
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc private func addChannelTapped() {
        present(addChannelAlert, animated: true)
    }
}

// MARK: - Data source

final class ChannelsListDataSource: UITableViewDiffableDataSource<ChannelSections, ChannelItem> {
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

// MARK: - Delegate

extension ChannelsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { Constants.headerHeight }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { Constants.rowHeight }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let channelItem = dataSource.itemIdentifier(for: indexPath) {
            let chatScreen = ChatViewController(channelId: channelItem.id)
            chatScreen.title = channelItem.name
            
            navigationController?.pushViewController(chatScreen, animated: true)
        } else {
            print("chat error")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let separatorView = UIView()
        separatorView.backgroundColor = .systemBackground
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.widthAnchor.constraint(equalTo: view.widthAnchor),
            separatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 1)
        ])
    }
}
