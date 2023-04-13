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
        
        coreDataChannels = channelsDataSource.getChannels()
        setupDataSource(with: coreDataChannels)
        
        fetchChannels()
        
        setupNavigationBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        setupTheme()
        fetchChannels()
    }

    // MARK: - Properties
    
    var currentTheme: UIUserInterfaceStyle = .light
    
    private lazy var channelsTableView = UITableView()
    private lazy var dataSource = ChannelsListDataSource(channelsTableView)
    private let channelsDataSource = ChannelsDataSource()

    private var coreDataChannels: [ChannelItem] = []

    private let refreshControl = UIRefreshControl()

    private var userDataRequest: Cancellable?
        
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
            
            self.createChannel(textField.text)
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
    
    private func setupTheme() {
        addChannelAlert.overrideUserInterfaceStyle = currentTheme
        errorAlert.overrideUserInterfaceStyle = currentTheme
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
    
    private func saveChannelsToCoreData(_ channels: [ChannelItem]) {
        for channel in channels {
            guard coreDataChannels.contains(channel) else {
                coreDataChannels.append(channel)
                channelsDataSource.saveChannelItem(with: channel)
                continue
            }
        }
    }
    
    @objc private func fetchChannels() {
        sharedChannelService.getChannels { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let channels):
                self.setupDataSource(with: channels)
                self.saveChannelsToCoreData(channels)
            case .failure(_):
                self.setupDataSource(with: self.coreDataChannels)
                self.present(self.errorAlert, animated: true)
            }
            
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc private func createChannel(_ channelName: String?) {
        guard let channelName = channelName else { return }
        
        sharedChannelService.createChannel(channelName) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(_):
                self.fetchChannels()
            case .failure(_):
                self.present(self.errorAlert, animated: true)
            }
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
            present(self.errorAlert, animated: true)
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

// MARK: - Delegates

extension ChannelsListViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        addChannelAlert.actions.first(where: { action in action.title == "Create" })?.isEnabled = textField.text != "" && textField.text != nil
    }
}
