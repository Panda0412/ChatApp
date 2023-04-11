//
//  ConversationsListViewController.swift
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
    static let cellIdentifier = "conversationsTableViewCell"
}

class ConversationsListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generateSomeData()
        
        setupNavigationBar()
        setupTableView()
        setupDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Properties
    
    private lazy var conversationsTableView = UITableView()
    
    private var conversations: [ConversationItem] = []
    
    private lazy var dataSource = ConversationsListDataSource(conversationsTableView)
        
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
    
    private func setupNavigationBar() {
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = "Back"
        
        navigationItem.setRightBarButton(
            UIBarButtonItem(title: "Add Channel", style: .plain, target: self, action: #selector(addChannelTapped)),
            animated: true
        )
    }
    
    private func setupTableView() {
        conversationsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(conversationsTableView)
        
        NSLayoutConstraint.activate([
            conversationsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            conversationsTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            conversationsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            conversationsTableView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
        
        conversationsTableView.register(ConversationsListTableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        conversationsTableView.delegate = self
    }
    
    private func setupDataSource() {
        var snapshot = dataSource.snapshot()
                
        snapshot.deleteAllItems()
        snapshot.appendSections(ConversationSections.allCases)
        snapshot.appendItems(conversations, toSection: .all)
        
        dataSource.apply(snapshot)
    }
    
    // MARK: - Helpers
    
    private func generateSomeData() {
        for index in 0..<10 {
            let time = Date().addingTimeInterval(-Double((86400 * index)))
            
            switch index {
            case 0:
                conversations.append(ConversationItem(
                    nickname: "Vasya Pupkin The Best Man In the World",
                    message: nil,
                    date: time,
                    isOnline: true,
                    hasUnreadMessages: false))
            case 1:
                conversations.append(ConversationItem(
                    nickname: "Panda0412",
                    message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate libero et velit interdum, ac aliquet odio mattis.",
                    date: time,
                    isOnline: true,
                    hasUnreadMessages: false))
            case 2:
                conversations.append(ConversationItem(
                    nickname: "Dmitry Puzyrev",
                    message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate libero et velit interdum, ac aliquet odio mattis.",
                    date: time,
                    isOnline: true,
                    hasUnreadMessages: true))
            default:
                conversations.append(ConversationItem(
                    nickname: "Anastasiia Bugaeva",
                    message: "Hello world!",
                    date: time,
                    isOnline: true,
                    hasUnreadMessages: false))
            }
        }
    }
    
    @objc private func addChannelTapped() {
        present(addChannelAlert, animated: true)
    }
}

// MARK: - Data source

final class ConversationsListDataSource: UITableViewDiffableDataSource<ConversationSections, ConversationItem> {
    init(_ tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? ConversationsListTableViewCell else {
                return UITableViewCell()
            }

            let model = ConversationCellModel(
                nickname: itemIdentifier.nickname,
                message: itemIdentifier.message,
                date: itemIdentifier.date,
                isOnline: itemIdentifier.isOnline,
                hasUnreadMessages: itemIdentifier.hasUnreadMessages
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

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { Constants.headerHeight }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { Constants.rowHeight }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let conversationScreen = ConversationViewController()
        conversationScreen.title = dataSource.itemIdentifier(for: indexPath)?.nickname
                
        navigationController?.pushViewController(conversationScreen, animated: true)
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
