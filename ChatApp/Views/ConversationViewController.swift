//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 07.03.2023.
//

import UIKit

private enum Constants {
    static let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height + 2
    static let customNavBarHeight: CGFloat = 88
    static let padding: CGFloat = -20
    static let textFieldMargin: CGFloat = 8
    static let cellIdentifier = "conversationTableViewCell"
}

class ConversationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        nickname = navigationItem.title ?? ""
        
        generateSomeData()
        
        setupTableView()
        setupDataSource()
        setupNavigationBar()
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidLayoutSubviews() {
        if needScrollToBottom {
            scrollToBottom()
        }
    }
    
    // MARK: - Properties
    
    private var nickname = ""
    private let dateFormatter = DateFormatter()
    private var needScrollToBottom = true
        
    private lazy var conversationTableView = UITableView(frame: .zero, style: .grouped)
    
    private var dates: [MessageSection] = []
    
    private lazy var dataSource = ConversationDataSource(conversationTableView)
    
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
            buttonImage.centerYAnchor.constraint(equalTo: button.centerYAnchor),
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
            button.widthAnchor.constraint(equalToConstant: 36),
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
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = ""
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(goBack))
        
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
        conversationTableView.rowHeight = UITableView.automaticDimension
        conversationTableView.estimatedRowHeight = 34
        
        conversationTableView.separatorStyle = .none
        conversationTableView.backgroundColor = .systemBackground
        conversationTableView.showsVerticalScrollIndicator = false
        
        conversationTableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        conversationTableView.allowsSelection = false
        conversationTableView.delegate = self
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        conversationTableView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        view.addSubview(conversationTableView)
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            conversationTableView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            conversationTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            conversationTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            conversationTableView.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -Constants.textFieldMargin),
            
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.textFieldMargin),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.textFieldMargin),
            textField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.textFieldMargin)
        ])
    }
    
    private func setupDataSource() {
        var snapshot = dataSource.snapshot()
                
        snapshot.deleteAllItems()
        snapshot.appendSections(dates)
        for section in dates {
            snapshot.appendItems(section.messages, toSection: section)
        }
                
        dataSource.apply(snapshot)
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
    
    @objc private func sendMessage() {
        print("SendMessage button tapped")
    }
    
    private func scrollToBottom() {
        conversationTableView.scrollToRow(at: IndexPath(row: dates[dates.count - 1].messages.count - 1, section: dates.count - 1), at: .bottom, animated: false)
    }

    private func generateSomeData() {
        for index in 0..<3 {
            let date = Date().addingTimeInterval(-Double((86400 * (index + 1))))

            var messages: [MessageItem] = []
            for msg in 0..<5 {
                messages.append(MessageItem(message: "Hello world!", date: date, isIncoming: msg % 2 == 0))
            }

            dates.append(MessageSection(date: date, messages: messages))
        }

        dates.reverse()
        
        let messages = [
            MessageItem(message: "Was so great to see you!", date: Date(), isIncoming: true),
            MessageItem(message: "We should catch up!", date: Date(), isIncoming: true),
            MessageItem(message: "Let’s get lunch soon! I’d glad to see you soon! 👀", date: Date(), isIncoming: false),
            MessageItem(message: "Let’s meet at Moe’s tomorrow", date: Date(), isIncoming: false),
            MessageItem(message: "OK", date: Date(), isIncoming: true),
            MessageItem(message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate libero et velit interdum, ac aliquet odio mattis.", date: Date(), isIncoming: true),
        ]
        dates.append(MessageSection(date: Date(), messages: messages))
    }
    
    private func isCurrentYear(_ date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date) == formatter.string(from: Date())
    }
}

// MARK: - Data source

final class ConversationDataSource: UITableViewDiffableDataSource<MessageSection, MessageItem> {
    init(_ tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? ConversationTableViewCell else {
                return UITableViewCell()
            }

            let model = MessageCellModel(message: itemIdentifier.message, date: itemIdentifier.date, isIncoming: itemIdentifier.isIncoming)
            
            cell.configure(with: model)
            
            return cell
        }
    }
}

// MARK: - Delegates

extension ConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 20 }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let date = dates[section].date
        dateFormatter.dateFormat = isCurrentYear(date) ? "dd MMMM" : "dd MMMM yyyy"
        
        let header = UILabel()
        header.text = dateFormatter.string(from: date)
        header.textAlignment = .center
        header.font = .systemFont(ofSize: 11, weight: .medium)
        header.textColor = .secondaryLabel
                
        return header
    }
}

extension ConversationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool { true }
}

extension ConversationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
