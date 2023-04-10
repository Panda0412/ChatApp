//
//  CustomNavigationBar.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 08.03.2023.
//

import UIKit

private enum Constants {
    static let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height + 2
    static let customNavBarHeight: CGFloat = 88
    static let padding: CGFloat = -20
    static let avatarSize: CGFloat = 50
}

class CustomNavigationBar: UIView {
    private var nickname = ""
    
    // MARK: - Init
    
    init(nickname: String) {
        super.init(frame: .zero)
        
        self.nickname = nickname
        
        [custumNavBar, backButton, avatar, nicknameLabel, separatorLine].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        [avatar, nicknameLabel, separatorLine].forEach { custumNavBar.addSubview($0) }
                        
        addSubview(custumNavBar)

        NSLayoutConstraint.activate([
            custumNavBar.heightAnchor.constraint(equalToConstant: Constants.customNavBarHeight + Constants.statusBarHeight),
            custumNavBar.widthAnchor.constraint(equalTo: widthAnchor),
            
            avatar.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatar.centerXAnchor.constraint(equalTo: custumNavBar.centerXAnchor),
            avatar.topAnchor.constraint(equalTo: custumNavBar.topAnchor, constant: Constants.statusBarHeight),
            
            nicknameLabel.centerXAnchor.constraint(equalTo: custumNavBar.centerXAnchor),
            nicknameLabel.bottomAnchor.constraint(equalTo: custumNavBar.bottomAnchor, constant: Constants.padding),
            
            separatorLine.heightAnchor.constraint(equalToConstant: 0.8),
            separatorLine.widthAnchor.constraint(equalTo: custumNavBar.widthAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: custumNavBar.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    
    private lazy var custumNavBar: UIView = {
        let navBar = UIView()
        
        navBar.backgroundColor = .secondarySystemFill
        
        return navBar
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        let buttonImage = UIImageView()
        
        let buttonImageConfig = UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 17), scale: .large)
        buttonImage.image = UIImage(systemName: "chevron.backward", withConfiguration: buttonImageConfig)
        buttonImage.tintColor = .systemBlue
        
        button.addSubview(buttonImage)
        
        buttonImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonImage.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            buttonImage.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        return button
    }()
    
    private lazy var avatar: AvatarView = {
        let avatar = AvatarView()
        
        let avatarData = AvatarModel(size: Constants.avatarSize, nickname: nickname)
        avatar.configure(with: avatarData)
        
        return avatar
    }()
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .label
        label.text = nickname
        
        return label
    }()
    
    private lazy var separatorLine: UIView = {
        let line = UIView()
        
        line.backgroundColor = .separator
        
        return line
    }()
}
