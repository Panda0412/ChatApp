//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 27.02.2023.
//

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var avatarView: UIView = {
        let avatar = UIView()
        
        avatar.frame.size = CGSize(width: 150, height: 150)
        
        let colorTop = CGColor(red: 0.95, green: 0.62, blue: 0.71, alpha: 1.00)
        let colorBottom = CGColor(red: 0.93, green: 0.48, blue: 0.58, alpha: 1.00)
                        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = avatar.bounds
        gradientLayer.cornerRadius = 75
        avatar.layer.addSublayer(gradientLayer)
        
        return avatar
    }()
    
    private lazy var avatarLabel: UILabel = {
        let avatarLabel = UILabel()
        
        avatarLabel.text = "SJ"
        if let descriptor = UIFont.systemFont(ofSize: 55, weight: .bold).fontDescriptor.withDesign(.rounded) {
            avatarLabel.font = UIFont(descriptor: descriptor, size: 55)
        } else {
            avatarLabel.font = UIFont.systemFont(ofSize: 55, weight: .bold)
        }
        avatarLabel.textColor = .white
        
        return avatarLabel
    }()
    
    private lazy var addPhotoButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Add Photo", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        
        return button
    }()
    
    private lazy var infoBlockView: UIStackView = {
        let info = UIStackView()
        
        info.axis = .vertical
        info.spacing = 10
        info.alignment = .center
        
        return info
    }()
    
    private lazy var nicknameLabel: UILabel = {
        let nickname = UILabel()
        
        nickname.text = "Stephen Johnson"
        nickname.textColor = .label
        
        return nickname
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let description = UILabel()
        
        description.text = "UX/UI designer, web designer Moscow, Russia"
        description.textColor = .secondaryLabel
        description.numberOfLines = 0
        description.textAlignment = .center
        
        return description
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .center
        
        return stack
    }()
    
    // MARK: - Lifecicle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        title = "My profile"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeModal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit")
        
        [avatarView,
         avatarLabel,
         addPhotoButton,
         infoBlockView,
         nicknameLabel,
         descriptionLabel,
         stackView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        avatarView.addSubview(avatarLabel)
        
        [nicknameLabel, descriptionLabel].forEach { infoBlockView.addArrangedSubview($0) }
        
        view.addSubview(stackView)
        
        [avatarView, addPhotoButton, infoBlockView].forEach { stackView.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: (navigationController?.navigationBar.frame.height ?? 0) + 32),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            avatarView.heightAnchor.constraint(equalToConstant: 150),
            avatarView.widthAnchor.constraint(equalTo: avatarView.heightAnchor),
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor)
        ])
    }
    
    @objc private func closeModal() {
        dismiss(animated: true)
    }
}
