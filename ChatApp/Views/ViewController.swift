//
//  ViewController.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.02.2023.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var profileButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.backgroundColor = .systemGreen
        button.setTitle("Profile", for: .normal)
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        button.addTarget(
            self,
            action: #selector(tapProfileButton),
            for: .touchUpInside
        )
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(profileButton)
                
        NSLayoutConstraint.activate([
            profileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc private func tapProfileButton() {
        let profileNavigation = UINavigationController(rootViewController: ProfileViewController())
        present(profileNavigation, animated: true)
    }
}

