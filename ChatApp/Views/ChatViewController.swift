//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 07.03.2023.
//

import UIKit

private enum Constants {
    static let statusBarHeight: CGFloat = (UIApplication.shared.windows
        .filter { $0.isKeyWindow }.first?
        .windowScene?.statusBarManager?.statusBarFrame.height ?? 0) + 2
    static let customNavBarHeight: CGFloat = 88
    static let padding: CGFloat = -20
    static let textFieldMargin: CGFloat = 8
    static let cellIdentifier = "chatTableViewCell"
}

class ChatViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchMessages()
        
        setupTableView()
        setupDataSource()
        setupNavigationBar()
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

//    override func viewDidLayoutSubviews() {
//        if needScrollToBottom {
//            scrollToBottom()
//        }
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(channelId: String) {
        self.channelId = channelId
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Properties
    
    private let chatService = ChannelService()
    
    private var channelId: String
    private var nickname = ""
    private let dateFormatter = DateFormatter()
//    private var needScrollToBottom = true
        
    private lazy var chatTableView = UITableView(frame: .zero, style: .grouped)
    private lazy var dataSource = ChatDataSource(chatTableView)
    
    private var chatSections: [MessageSection] = []
    
    // MARK: - UI Elements
    
    private lazy var navBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar(nickname: nickname)
        
        navBar.translatesAutoresizingMaskIntoConstraints = false
        
        return navBar
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        let buttonImage = UIImageView()
        
        let buttonImageConfig = UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 17), scale: .large)
        buttonImage.image = UIImage(systemName: "chevron.backward", withConfiguration: buttonImageConfig)
        buttonImage.tintColor = .systemBlue
        
        button.addSubview(buttonImage)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        buttonImage.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            buttonImage.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            buttonImage.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        return button
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        let buttonImage = UIImageView()
        
        buttonImage.image = UIImage(systemName: "arrow.up.circle.fill")
        buttonImage.tintColor = .systemBlue
        
        button.addSubview(buttonImage)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        buttonImage.translatesAutoresizingMaskIntoConstraints = false
                
        NSLayoutConstraint.activate([
            buttonImage.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            buttonImage.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            buttonImage.heightAnchor.constraint(equalToConstant: 28),
            buttonImage.widthAnchor.constraint(equalToConstant: 28),
            button.heightAnchor.constraint(equalToConstant: 36),
            button.widthAnchor.constraint(equalToConstant: 36)
        ])
        
        return button
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        
        field.placeholder = "Type message"
        field.font = UIFont.systemFont(ofSize: 17)
        field.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        field.layer.cornerRadius = 18
        field.layer.borderColor = UIColor.separator.cgColor
        field.layer.borderWidth = 1
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 13, height: field.frame.height))
        field.leftViewMode = .always
        
        field.rightView = sendButton
        field.rightViewMode = .always
        
        field.delegate = self
        
        return field
    }()
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        nickname = navigationItem.title ?? ""
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
                        
        navBar.addSubview(backButton)
        view.addSubview(navBar)
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 10),
            backButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor, constant: (Constants.statusBarHeight + Constants.padding) / 2),
            
            navBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            navBar.heightAnchor.constraint(equalToConstant: Constants.customNavBarHeight + Constants.statusBarHeight),
            navBar.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    private func setupTableView() {
        chatTableView.rowHeight = UITableView.automaticDimension
        chatTableView.estimatedRowHeight = 42
        
        chatTableView.separatorStyle = .none
        chatTableView.backgroundColor = .systemBackground
        chatTableView.showsVerticalScrollIndicator = false
        
        chatTableView.register(ChatTableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        chatTableView.allowsSelection = false
        chatTableView.delegate = self
        
        chatTableView.keyboardDismissMode = .onDrag
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        chatTableView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        view.addSubview(chatTableView)
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            chatTableView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatTableView.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -Constants.textFieldMargin),
            
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.textFieldMargin),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.textFieldMargin),
            textField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.textFieldMargin)
        ])
    }
    
    private func setupDataSource() {
        var snapshot = dataSource.snapshot()
        
        snapshot.deleteAllItems()
        snapshot.appendSections(chatSections)
        
        for section in chatSections {
            snapshot.appendItems(section.messages, toSection: section)
        }
                
        dataSource.apply(snapshot, animatingDifferences: false)
        
        scrollToBottom()
    }
    
    // MARK: - Keyboard observers
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRect.height - self.view.safeAreaInsets.bottom, right: 0)
            self.view.layoutIfNeeded()
        }
        
        scrollToBottom()
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Helpers
    
    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    private func scrollToBottom() {
        guard !chatSections.isEmpty else {
            return
        }
        
        let section = chatSections.isEmpty ? 0 : chatSections.count - 1
        let row = chatSections[section].messages.isEmpty ? 0 : chatSections[section].messages.count - 1
        
        chatTableView.scrollToRow(at: IndexPath(row: row, section: section), at: .bottom, animated: false)
    }
    
    private func fetchMessages() {
        chatService.getChannelMessages(for: channelId) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let messages):
                if messages.isEmpty { return }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMM yyyy"
                
                var currentSectionDate = messages[0].date
                var currentSectionMessages: [MessageItem] = []
                
                for (index, message) in messages.enumerated() {
                    let prevMessage = index != 0 ? messages[index - 1] : nil
                    var currentMessage = message
                    let nextMessage = index != messages.count - 1 ? messages[index + 1] : nil
                    
                    if currentMessage.userID != prevMessage?.userID {
                        currentMessage.isNicknameNeeded = true
                    }
                    if let nextMessage = nextMessage,
                        currentMessage.userID != nextMessage.userID ||
                        formatter.string(from: currentSectionDate) != formatter.string(from: nextMessage.date) {
                        currentMessage.isBubbleTailNeeded = true
                    }
                    
                    if formatter.string(from: currentMessage.date) == formatter.string(from: currentSectionDate) {
                        currentSectionMessages.append(currentMessage)
                    } else {
                        if !currentSectionMessages.isEmpty {
                            self.chatSections.append(MessageSection(date: currentSectionDate, messages: currentSectionMessages))
                        }
                        currentMessage.isNicknameNeeded = true
                        currentSectionDate = currentMessage.date
                        currentSectionMessages = [currentMessage]
                    }
                }
                
                self.chatSections.append(MessageSection(date: currentSectionDate, messages: currentSectionMessages))
                self.setupDataSource()
                
            case .failure(let error):
                print("Error", error)
            }
        }
    }
    
    @objc private func sendMessage() {
        print("SendMessage button tapped")
    }
    
    private func isCurrentYear(_ date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date) == formatter.string(from: Date())
    }
}

// MARK: - Data source

final class ChatDataSource: UITableViewDiffableDataSource<MessageSection, MessageItem> {
    init(_ tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? ChatTableViewCell else {
                return UITableViewCell()
            }

            let model = MessageCellModel(
                userName: itemIdentifier.userName,
                message: itemIdentifier.text,
                date: itemIdentifier.date,
                isIncoming: true,
                isBubbleTailNeeded: itemIdentifier.isBubbleTailNeeded,
                isNicknameNeeded: itemIdentifier.isNicknameNeeded
            )
            
            cell.configure(with: model)
            
            return cell
        }
    }
}

// MARK: - Delegates

extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 20 }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let date = chatSections[section].date
        dateFormatter.dateFormat = isCurrentYear(date) ? "dd MMMM" : "dd MMMM yyyy"
        
        let header = UILabel()
        header.text = dateFormatter.string(from: date)
        header.textAlignment = .center
        header.font = .systemFont(ofSize: 11, weight: .medium)
        header.textColor = .secondaryLabel
                
        return header
    }
}

extension ChatViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool { true }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
