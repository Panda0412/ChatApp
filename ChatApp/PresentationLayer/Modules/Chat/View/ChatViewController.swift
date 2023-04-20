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
        
        presenter.viewIsReady()
        
        setupTableView()
        setupNavigationBar()
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    init(output: ChatViewOutput) {
        self.presenter = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    private let presenter: ChatViewOutput
    
    private var nickname = ""
    private let dateFormatter = DateFormatter()
        
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
        
        let buttonImageConfig = UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 17), scale: .large)
        
        let buttonImage = UIImage(systemName: "chevron.backward", withConfiguration: buttonImageConfig)?
            .withTintColor(.systemBlue)
            .withRenderingMode(.alwaysOriginal)
        
        button.setImage(buttonImage, for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
                
        return button
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.isEnabled = false
        
        let grayButtonImage = UIImage(systemName: "arrow.up.circle.fill")?
            .withTintColor(.systemGray)
            .withRenderingMode(.alwaysOriginal)
        
        let blueButtonImage = UIImage(systemName: "arrow.up.circle.fill")?
            .withTintColor(.systemBlue)
            .withRenderingMode(.alwaysOriginal)
                
        button.setImage(grayButtonImage, for: .disabled)
        button.setImage(blueButtonImage, for: .normal)
        
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 36),
            button.widthAnchor.constraint(equalToConstant: 36)
        ])
        
        return button
    }()
    
    private lazy var messageTextField: UITextField = {
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
    
    lazy var errorAlert: UIAlertController = {
        let alert = UIAlertController(title: "Ooops!", message: "Something went wrong", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default)

        alert.addAction(dismissAction)

        return alert
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
        
        [sendButton,
         chatTableView,
         messageTextField].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        view.addSubview(chatTableView)
        view.addSubview(messageTextField)
        
        NSLayoutConstraint.activate([
            chatTableView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatTableView.bottomAnchor.constraint(equalTo: messageTextField.topAnchor, constant: -Constants.textFieldMargin),
            
            messageTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            messageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.textFieldMargin),
            messageTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.textFieldMargin),
            messageTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.textFieldMargin)
        ])
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
    
    private func scrollToBottom(animated: Bool = false) {
        guard !chatSections.isEmpty else {
            return
        }
        
        let section = chatSections.isEmpty ? 0 : chatSections.count - 1
        let row = chatSections[section].messages.isEmpty ? 0 : chatSections[section].messages.count - 1
        
        chatTableView.scrollToRow(at: IndexPath(row: row, section: section), at: .bottom, animated: animated)
    }
    
    @objc private func sendMessage() {
        guard let messageText = messageTextField.text else { return }
        
        presenter.sendMessage(messageText)
    }
    
    private func isCurrentYear(_ date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date) == formatter.string(from: Date())
    }
}

extension ChatViewController: ChatViewInput {
    func showData(_ sections: [MessageSection], animated: Bool) {
        chatSections = sections
        
        var snapshot = dataSource.snapshot()
        
        snapshot.deleteAllItems()
        snapshot.appendSections(sections)
        
        for section in sections {
            snapshot.appendItems(section.messages, toSection: section)
        }
                
        dataSource.apply(snapshot, animatingDifferences: false)
        
        scrollToBottom(animated: animated)
    }
    
    func showAlert() {
        present(errorAlert, animated: true)
    }
    
    func clearTextField() {
        messageTextField.text = ""
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
                isIncoming: itemIdentifier.userID != ChannelService.shared.userId,
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
        var date: Date
        
        let header = UILabel()
        header.textAlignment = .center
        header.font = .systemFont(ofSize: 11, weight: .medium)
        header.textColor = .secondaryLabel
        
        if chatSections.count > section {
            date = chatSections[section].date
        } else {
            header.text = "Date parsing error"
            return header
        }
        
        dateFormatter.dateFormat = isCurrentYear(date) ? "dd MMMM" : "dd MMMM yyyy"
        header.text = dateFormatter.string(from: date)
                
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
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        sendButton.isEnabled = messageTextField.text != "" && messageTextField.text != nil
    }
}
