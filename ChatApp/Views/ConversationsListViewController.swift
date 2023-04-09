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
    static let themeKey = "theme"
}

class ConversationsListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generateSomeData()
        fetchUserData()
        
        setupTheme()
        setupNavigationBar()
        setupTableView()
        setupDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Properties
    
    private lazy var conversationsTableView = UITableView()
    
    private var onlineConversations: [ConversationItem] = []
    private var historyConversations: [ConversationItem] = []
    
    private lazy var dataSource = ConversationsListDataSource(conversationsTableView)
    
    var currentTheme: UIUserInterfaceStyle = .light
    
    private var userDataRequest: Cancellable?
    private lazy var avatarButton = UIButton()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - UI Elements
    
    private func setupProfileButton(with userData: UserProfileViewModel) -> UIButton {
        let button = UIButton()
        
        let avatarView = AvatarView()
        let avatarData = AvatarModel(size: Constants.avatarSize, nickname: userData.nickname, image: userData.image?.image)
        avatarView.configure(with: avatarData)
        
        button.addSubview(avatarView)
        button.addTarget(self, action: #selector(openProfile), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        return button
    }
    
    // MARK: - Setup
    private func setupTheme() {
        let storedTheme = UIUserInterfaceStyle.init(rawValue: defaults.integer(forKey: Constants.themeKey))
        guard storedTheme == .light || storedTheme == .dark else { return }
        
        currentTheme = storedTheme ?? .light
    }
    
    private func setupNavigationBar() {
        view.backgroundColor = .systemBackground
        title = "Chat"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backButtonTitle = "Back"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(openSettings))
        
        navigationController?.overrideUserInterfaceStyle = currentTheme
        avatarButton.overrideUserInterfaceStyle = currentTheme
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
        snapshot.appendItems(onlineConversations, toSection: .online)
        snapshot.appendItems(historyConversations, toSection: .history)
        
        dataSource.apply(snapshot)
    }
    
    // MARK: - Helpers
    
    private func generateSomeData() {
        for index in 0..<10 {
            let time = Date().addingTimeInterval(-Double((86400 * index)))
            
            switch index {
                case 0:
                    onlineConversations.append(ConversationItem(nickname: "Vasya Pupkin The Best Man In the World", message: nil, date: time, isOnline: true, hasUnreadMessages: false))
                    historyConversations.append(ConversationItem(nickname: "Vasya Pupkin", message: nil, date: time, isOnline: false, hasUnreadMessages: false))
                case 1:
                    onlineConversations.append(ConversationItem(nickname: "Panda0412", message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate libero et velit interdum, ac aliquet odio mattis.", date: time, isOnline: true, hasUnreadMessages: false))
                    historyConversations.append(ConversationItem(nickname: "Panda0412", message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate libero et velit interdum, ac aliquet odio mattis.", date: time, isOnline: false, hasUnreadMessages: false))
                case 2:
                    onlineConversations.append(ConversationItem(nickname: "Dmitry Puzyrev", message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate libero et velit interdum, ac aliquet odio mattis.", date: time, isOnline: true, hasUnreadMessages: true))
                    historyConversations.append(ConversationItem(nickname: "Dmitry Puzyrev", message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate libero et velit interdum, ac aliquet odio mattis.", date: time, isOnline: false, hasUnreadMessages: true))
                default:
                    onlineConversations.append(ConversationItem(nickname: "Anastasiia Bugaeva", message: "Hello world!", date: time, isOnline: true, hasUnreadMessages: false))
                    historyConversations.append(ConversationItem(nickname: "Anastasiia Bugaeva", message: "Hello world!", date: time, isOnline: false, hasUnreadMessages: false))
            }
        }
    }
    
    private func fetchUserData() {
        userDataRequest = sharedCombineService.getProfileDataPublisher
            .sink { [weak self] userData in
                guard let self else { return }
                self.avatarButton = self.setupProfileButton(with: userData)
            }
    }
    
    /*
     Если вынести инициализацию ThemesViewController сюда, то ConversationsListViewController будет держать на него ссылку, а ThemesViewController будет держать ссылку на ConversationsListViewController в качестве делегата, из-за чего возникает Retain cycle
     При создании ThemesViewController внутри функции openSettings, утечки памяти не происходит (я проверила 😊)
     В замыкании передаётся слабая ссылка на ConversationsListViewController, что позволяет избежать Retain cycle, где бы не создавался ThemesViewController
     */
//    let settingsScreen = ThemesViewController()
    
    @objc private func openSettings() {
        let settingsScreen = ThemesViewController()
        
        // Delegate
        settingsScreen.delegate = self
        
        // Closure
//        settingsScreen.changeUserInterfaceStyleClosure = { [weak self] theme in
//            self?.navigationController?.overrideUserInterfaceStyle = theme
//            self?.currentTheme = theme
//        }
//        settingsScreen.currentTheme = currentTheme
        
        navigationController?.pushViewController(settingsScreen, animated: true)
    }
    
    @objc private func openProfile() {
        let profile = ProfileViewController()
        profile.configure(with: UserProfileViewModel(nickname: nil, description: nil))
        profile.currentTheme = currentTheme
        
        let profileNavigation = UINavigationController(rootViewController: profile)

        present(profileNavigation, animated: true)
    }
}

// MARK: - Data source

final class ConversationsListDataSource: UITableViewDiffableDataSource<ConversationSections, ConversationItem> {
    init(_ tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? ConversationsListTableViewCell else {
                return UITableViewCell()
            }

            let model = ConversationCellModel(nickname: itemIdentifier.nickname, message: itemIdentifier.message, date: itemIdentifier.date, isOnline: itemIdentifier.isOnline, hasUnreadMessages: itemIdentifier.hasUnreadMessages)
            
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
        
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "ONLINE"
            
            case 1:
                return "HISTORY"
                
            default:
                return nil
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

extension ConversationsListViewController: ThemesPickerDelegate {
    func changeUserInterfaceStyle(theme: UIUserInterfaceStyle) {
        navigationController?.overrideUserInterfaceStyle = theme
        avatarButton.overrideUserInterfaceStyle = theme
        currentTheme = theme
        defaults.set(theme.rawValue, forKey: Constants.themeKey)
    }
}
