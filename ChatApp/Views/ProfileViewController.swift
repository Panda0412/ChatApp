//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 27.02.2023.
//

import UIKit

private enum Constants {
    static let avatarSize: CGFloat = 150
}

class ProfileViewController: UIViewController, ConfigurableViewProtocol {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: - Properties
    
    private var nickname = ""
    
    // MARK: - UI Elements
    
    private lazy var avatarView: AvatarView = {
        let avatar = AvatarView()
        
        let avatarData = AvatarModel(size: Constants.avatarSize, nickname: nickname)
        avatar.configure(with: avatarData)
        
        return avatar
    }()
    
    private lazy var addPhotoButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Add Photo", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        
        button.addTarget(
            self,
            action: #selector(presentAddPhotoActionSheet),
            for: .touchUpInside
        )
        
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
        
        nickname.text = self.nickname
        nickname.textColor = .label
        nickname.font = UIFont.preferredFont(forTextStyle: .headline).withSize(22)
                
        return nickname
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let description = UILabel()
        
        description.text = "UX/UI designer, web designer Moscow, Russia"
        description.textColor = .secondaryLabel
        description.numberOfLines = 0
        description.textAlignment = .center
        description.font = UIFont.preferredFont(forTextStyle: .body)
                
        return description
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .center
        
        return stack
    }()
    
    private lazy var avatarActionSheet: UIAlertController = {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
        let makePhotoAction = UIAlertAction(title: "Сделать фото", style: .default) { [self] (action) in
            addAvatar(withCamera: true)
        }
        let openPhotoLibraryAction = UIAlertAction(title: "Выбрать из галереи", style: .default) { [self] (action) in
            addAvatar()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        [makePhotoAction, openPhotoLibraryAction, cancelAction].forEach { actionSheet.addAction($0) }
        
        return actionSheet
    }()
    
    private lazy var cameraAlert: UIAlertController = {
        let alert = UIAlertController(title: "Ошибка", message: "Камера недоступна", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(dismissAction)

        return alert
    }()
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "My profile"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeModal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit")
        
        [avatarView,
         addPhotoButton,
         infoBlockView,
         nicknameLabel,
         descriptionLabel,
         stackView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        [nicknameLabel, descriptionLabel].forEach { infoBlockView.addArrangedSubview($0) }
        
        [avatarView, addPhotoButton, infoBlockView].forEach { stackView.addArrangedSubview($0) }
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: (navigationController?.navigationBar.frame.height ?? 0) + 32),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            avatarView.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
        ])
    }
    
    // MARK: - Helpers
    
    @objc private func closeModal() {
        dismiss(animated: true)
    }
    
    @objc private func presentAddPhotoActionSheet() {
        present(avatarActionSheet, animated: true)
    }
    
    private func addAvatar(withCamera: Bool = false) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        if withCamera {
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                present(cameraAlert, animated: true)
                return
            }
            picker.sourceType = .camera
        }
        
        present(picker, animated: true)
    }
    
    func configure(with model: UserProfileViewModel) {
        nickname = model.nickname
        if let description = model.description {
            descriptionLabel.text = description
        }
        if let avatar = model.image {
            avatarView.setAvatarImage(image: avatar)
        }
    }
}

// MARK: - Delegate

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        
        guard let avatar = info[.editedImage] as? UIImage else { return }
        
        avatarView.setAvatarImage(image: avatar)
    }
}
