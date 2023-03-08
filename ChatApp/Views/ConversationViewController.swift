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
}

class ConversationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        nickname = navigationItem.title ?? ""
        
        setupNavigationBar()
    }
    
    // MARK: - Properties
    
    private var nickname = ""
    
    // MARK: - UI Elements
    
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
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = ""
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(goBack))
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        let navBar = CustomNavigationBar(nickname: nickname)
                
        navBar.addSubview(backButton)
        view.addSubview(navBar)
        
        navBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 10),
            backButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor, constant: (Constants.statusBarHeight + Constants.padding) / 2),
            
            navBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            navBar.heightAnchor.constraint(equalToConstant: Constants.customNavBarHeight + Constants.statusBarHeight),
        ])
    }
    
    // MARK: - Helpers
    
    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Delegate

extension ConversationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
