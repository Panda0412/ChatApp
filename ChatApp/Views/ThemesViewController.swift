//
//  ThemesViewController.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 14.03.2023.
//

import UIKit

private enum Constants {
    static let margin: CGFloat = 16
    static let padding: CGFloat = 24
    static let messagesMargin: CGFloat = 7
    static let messagesPadding: CGFloat = 5
    static let messagesBlueColor = UIColor(red: 0.27, green: 0.54, blue: 0.97, alpha: 1)
}

enum TailDirection {
    case right
    case left
}

class ThemesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupUI()
    }
    
    // MARK: - Properties
    
    // Delegate
    var delegate: ThemesPickerDelegate?
    
    // Closure
//    var changeUserInterfaceStyleClosure: ((UIUserInterfaceStyle) -> ())?
//    var currentTheme: UIUserInterfaceStyle? = .unspecified
    
    // MARK: - UI Elements

    private lazy var contentView: UIView = {
        let contentView = UIView()
        
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 10
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        return contentView
    }()
    
    private lazy var leftStack = setupVerticalStack(for: .light)
    private lazy var lightMessagesView = setupMessagesView(for: .light)
    private lazy var lightButtonTitle = setupButtonTitle(with: "Day")
    private lazy var lightThemeButton = setupThemeButton(for: .light)
    
    private lazy var rightStack = setupVerticalStack(for: .dark)
    private lazy var darkMessagesView = setupMessagesView(for: .dark)
    private lazy var darkButtonTitle = setupButtonTitle(with: "Night")
    private lazy var darkThemeButton = setupThemeButton(for: .dark)

    // MARK: - Setup UI Elements
    
    private func setupVerticalStack(for theme: UIUserInterfaceStyle) -> UIStackView {
        let stack = UIStackView()

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        
        switch theme {
            case .light:
                [lightMessagesView, lightButtonTitle, lightThemeButton].forEach { stack.addArrangedSubview($0) }
            case .dark:
                [darkMessagesView, darkButtonTitle, darkThemeButton].forEach { stack.addArrangedSubview($0) }
            default: break
        }

        stack.translatesAutoresizingMaskIntoConstraints = false
                
        return stack
    }
    
    private func setupMessagesView(for theme: UIUserInterfaceStyle) -> UIView {
        let messagesView = UIView()
        let outcomingMessageView = setupMessageBubble(isIncoming: false)
        let incomingMessageView = setupMessageBubble(isIncoming: true)
        
        messagesView.overrideUserInterfaceStyle = theme
        messagesView.backgroundColor = .systemBackground
        messagesView.layer.cornerRadius = 7
        messagesView.layer.borderColor = UIColor.opaqueSeparator.cgColor
        messagesView.layer.borderWidth = 0.5
        
        switch theme {
            case .light:
                messagesView.layer.borderColor = UIColor.lightGray.cgColor
            case .dark:
                messagesView.layer.borderColor = UIColor.darkGray.cgColor
            default: break
        }
                
        messagesView.addSubview(outcomingMessageView)
        messagesView.addSubview(incomingMessageView)
        
        NSLayoutConstraint.activate([
            messagesView.widthAnchor.constraint(equalTo: outcomingMessageView.widthAnchor, multiplier: 4 / 3, constant: Constants.messagesMargin * 2),
            
            outcomingMessageView.trailingAnchor.constraint(equalTo: messagesView.trailingAnchor, constant: -Constants.messagesMargin),
            incomingMessageView.leadingAnchor.constraint(equalTo: messagesView.leadingAnchor, constant: Constants.messagesMargin),
            
            outcomingMessageView.topAnchor.constraint(equalTo: messagesView.topAnchor, constant: Constants.messagesMargin),
            incomingMessageView.topAnchor.constraint(equalTo: outcomingMessageView.bottomAnchor, constant: Constants.messagesPadding),
            incomingMessageView.bottomAnchor.constraint(equalTo: messagesView.bottomAnchor, constant: -Constants.messagesMargin)
        ])
        
        messagesView.isUserInteractionEnabled = true
        messagesView.translatesAutoresizingMaskIntoConstraints = false
        
        return messagesView
    }
    
    private func setupMessageBubble(isIncoming: Bool) -> UIView {
        let messageView = UIView()
        let tail = isIncoming ? setupBubbleTail(.left) : setupBubbleTail(.right)
        
        messageView.backgroundColor = isIncoming ? .systemGray5 : Constants.messagesBlueColor
        messageView.layer.cornerRadius = 9

        messageView.addSubview(tail)
        
        NSLayoutConstraint.activate([
            messageView.heightAnchor.constraint(equalToConstant: 18),
            messageView.widthAnchor.constraint(equalToConstant: 50),

            isIncoming ? tail.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -2.5) : tail.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: 2.5),
            tail.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -0.7),
            tail.heightAnchor.constraint(equalToConstant: 10.5),
            tail.widthAnchor.constraint(equalToConstant: 8.5),
        ])
        
        messageView.translatesAutoresizingMaskIntoConstraints = false
        
        return messageView
    }
    
    private func setupBubbleTail(_ direction: TailDirection) -> UIImageView {
        let tail = UIImageView()
        let tailImage = UIImage(named: "bubble_tail")
        
        switch direction {
            case .right:
                tail.image = tailImage?.withRenderingMode(.alwaysTemplate)
                tail.tintColor = Constants.messagesBlueColor
                
            case .left:
                tail.image = tailImage?.withRenderingMode(.alwaysTemplate).withHorizontallyFlippedOrientation()
                tail.tintColor = .systemGray5
        }
        
        tail.translatesAutoresizingMaskIntoConstraints = false
                
        return tail
    }
    
    private func setupButtonTitle(with text: String) -> UILabel {
        let buttonTitle = UILabel()
        
        buttonTitle.font = .systemFont(ofSize: 17)
        buttonTitle.textColor = .label
        buttonTitle.text = text
        
        buttonTitle.isUserInteractionEnabled = true
        buttonTitle.translatesAutoresizingMaskIntoConstraints = false
        
        return buttonTitle
    }
    
    private func setupThemeButton(for theme: UIUserInterfaceStyle) -> ThemeButton {
        let button = ThemeButton(theme: theme)
                
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        button.setImage(UIImage(systemName: "circle")?.withTintColor(.systemGray2, renderingMode: .alwaysOriginal), for: .normal)
        
        // Delegate
        button.isSelected = theme == delegate?.currentTheme
        // Closure
//        button.isSelected = theme == currentTheme

        button.isUserInteractionEnabled = !button.isSelected
        
        button.addTarget(self, action: #selector(themeButtonAction(sender:)), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
                
        return button
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        view.backgroundColor = .secondarySystemBackground
        title = "Settings"
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupUI() {
        lightMessagesView.addGestureRecognizer(lightThemeTapGestureRecognizer())
        darkMessagesView.addGestureRecognizer(darkThemeTapGestureRecognizer())
        lightButtonTitle.addGestureRecognizer(lightThemeTapGestureRecognizer())
        darkButtonTitle.addGestureRecognizer(darkThemeTapGestureRecognizer())

        contentView.addSubview(leftStack)
        contentView.addSubview(rightStack)
                
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.margin),
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.margin),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.margin),
            
            leftStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.padding),
            leftStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.padding),
            
            rightStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.padding),
            rightStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.padding),
            
            leftStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            leftStack.trailingAnchor.constraint(equalTo: contentView.centerXAnchor),
            rightStack.leadingAnchor.constraint(equalTo: leftStack.trailingAnchor),
            rightStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    // MARK: - Helpers
    
    @objc private func themeButtonAction(sender: ThemeButton) {        
        switch sender.theme {
            case .light:
                lightThemeButton.isSelected = true
                lightThemeButton.isUserInteractionEnabled = false
                darkThemeButton.isSelected = false
                darkThemeButton.isUserInteractionEnabled = true
            case .dark:
                darkThemeButton.isSelected = true
                darkThemeButton.isUserInteractionEnabled = false
                lightThemeButton.isSelected = false
                lightThemeButton.isUserInteractionEnabled = true
            default: break
        }
        
        // Delegate
        delegate?.changeUserInterfaceStyle(theme: sender.theme)
        // Closure
//        changeUserInterfaceStyleClosure?(sender.theme)
    }
    
    private func lightThemeTapGestureRecognizer() -> ThemeTapGestureRecognizer {
        ThemeTapGestureRecognizer(target: self, action: #selector(themeButtonAction(sender:)), theme: .light)
    }
    
    private func darkThemeTapGestureRecognizer() -> ThemeTapGestureRecognizer {
        ThemeTapGestureRecognizer(target: self, action: #selector(themeButtonAction(sender:)), theme: .dark)
    }

}
