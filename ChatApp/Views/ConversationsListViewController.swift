//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 05.03.2023.
//

import UIKit

class ConversationsListViewController: UIViewController {
    private var avatarButton: UIButton = {
        let button = UIButton()
        
        let avatar = AvatarView()
        let avatarData = AvatarModel(size: 32, nickname: "Anastasiia Bugaeva")
        avatar.configure(with: avatarData)
                
        button.addSubview(avatar)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Chat"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        
        avatarButton.addTarget(self, action: #selector(openProfile), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(openSettings))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: avatarButton)
    }
    
    @objc private func openSettings() {
        print("Settings button tapped")
    }
    
    @objc private func openProfile() {
        let profileNavigation = UINavigationController(rootViewController: ProfileViewController())
        present(profileNavigation, animated: true)
    }
}
