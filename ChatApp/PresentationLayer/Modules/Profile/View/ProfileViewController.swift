//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 27.02.2023.
//

import Combine
import UIKit

private enum Constants {
    static let avatarSize: CGFloat = 150
    static let margin: CGFloat = 32
}

enum TextFieldPurpose {
    case nickname
    case description
}

class ProfileViewController: UIViewController, ConfigurableViewProtocol {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

        presenter.viewIsReady()
        themesService.viewIsReady()
        
        setupUI()
    }
    
    init(output: ProfileViewOutput, themesService: ThemesServiceInput) {
        self.presenter = output
        self.themesService = themesService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    private let presenter: ProfileViewOutput
    private let themesService: ThemesServiceInput
    
    var currentTheme: UIUserInterfaceStyle = .light
    private var currentUserData = UserProfileViewModel()
    
    private var isButtonAnimated = false
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private lazy var cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelEditMode))
    private lazy var saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveData))
    private lazy var activityIndicatorBarItem = UIBarButtonItem(customView: activityIndicator)
    
    // MARK: - UI Elements
    
    private lazy var avatarView: AvatarView = {
        let avatar = AvatarView()
        
        let avatarData = AvatarModel(size: Constants.avatarSize, nickname: currentUserData.nickname)
        avatar.configure(with: avatarData)
        
        return avatar
    }()
    
    private lazy var addPhotoButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Add Photo", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(presentAddPhotoActionSheet), for: .touchUpInside)
        
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

        nickname.text = currentUserData.nickname ?? "No name"
        nickname.textColor = .label
        nickname.font = UIFont.preferredFont(forTextStyle: .headline).withSize(22)

        return nickname
    }()

    private lazy var descriptionLabel: UILabel = {
        let description = UILabel()

        description.text = currentUserData.description ?? "No bio specified"
        description.textColor = .secondaryLabel
        description.numberOfLines = 0
        description.textAlignment = .center
        description.font = UIFont.preferredFont(forTextStyle: .body)

        return description
    }()
    
    private func setupTextField(for purpose: TextFieldPurpose) -> UITextField {
        let field = UITextField()
        let fieldLabelView = UIView()
        let label = UILabel()
        
        let separatorLine = UIView()
        let bottomSeparatorLine = UIView()
        separatorLine.backgroundColor = .separator
        bottomSeparatorLine.backgroundColor = .separator
        
        label.font = UIFont.systemFont(ofSize: 17)
        
        field.backgroundColor = .systemBackground
        field.font = UIFont.systemFont(ofSize: 17)
        field.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
                
        fieldLabelView.addSubview(label)
        
        field.leftView = fieldLabelView
        field.leftViewMode = .always
        
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: field.frame.height))
        field.rightViewMode = .always
        
        field.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        [field, fieldLabelView, label, separatorLine, bottomSeparatorLine].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        field.addSubview(separatorLine)

        switch purpose {
        case .nickname:
            label.text = "Name"
            field.placeholder = "Enter your name"
            field.text = currentUserData.nickname
        case .description:
            label.text = "Bio"
            field.placeholder = "Tell about yourself"
            field.text = currentUserData.description
            field.addSubview(bottomSeparatorLine)
            NSLayoutConstraint.activate([
                bottomSeparatorLine.heightAnchor.constraint(equalToConstant: 0.5),
                bottomSeparatorLine.widthAnchor.constraint(equalTo: field.widthAnchor),
                bottomSeparatorLine.bottomAnchor.constraint(equalTo: field.bottomAnchor)
            ])
        }
        
        field.delegate = self
        
        NSLayoutConstraint.activate([
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            separatorLine.widthAnchor.constraint(equalTo: field.widthAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: field.leadingAnchor, constant: purpose == .description ? 16 : 0),
            
            field.heightAnchor.constraint(equalToConstant: 44),
            fieldLabelView.heightAnchor.constraint(equalToConstant: 44),
            fieldLabelView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.3),
            label.leadingAnchor.constraint(equalTo: fieldLabelView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: fieldLabelView.centerYAnchor)
        ])
        
        return field
    }
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = .systemBlue
        button.setTitle("Edit Profile", for: .normal)
        button.layer.cornerRadius = 14
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        
        button.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(animateEditButton)))
        button.addTarget(self, action: #selector(switchToEditMode), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .center
        
        return stack
    }()
    
    lazy var avatarActionSheet: UIAlertController = {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                        
        let makePhotoAction = UIAlertAction(title: "Сделать фото", style: .default) { [self] _ in
            addAvatar(withCamera: true)
        }
        let openPhotoLibraryAction = UIAlertAction(title: "Выбрать из галереи", style: .default) { [self] _ in
            addAvatar()
        }
        let loadNetworkPhotosAction = UIAlertAction(title: "Загрузить из интернета", style: .default) { [self] _ in
            
            let networkPhotosCollection = NetworkPhotosCollectionModuleAssembly().makeNetworkPhotosCollectionModule(profile: self)
            
            present(UINavigationController(rootViewController: networkPhotosCollection), animated: true)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        [makePhotoAction, openPhotoLibraryAction, loadNetworkPhotosAction, cancelAction].forEach { actionSheet.addAction($0) }
        
        return actionSheet
    }()
    
    private lazy var cameraAlert: UIAlertController = {
        let alert = UIAlertController(title: "Ошибка", message: "Камера недоступна", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(dismissAction)

        return alert
    }()
    
    lazy var successAlert: UIAlertController = {
        let alert = UIAlertController(title: "Success", message: "You are breathtaking", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.cancelEditMode()
        }

        alert.addAction(dismissAction)

        return alert
    }()
    
    lazy var errorAlert: UIAlertController = {
        let alert = UIAlertController(title: "Could not save profile", message: "Try again", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.cancelEditMode()
        }
        let retryAction = UIAlertAction(title: "Try Again", style: .cancel) { [weak self] _ in
            self?.saveData()
        }

        alert.addAction(dismissAction)
        alert.addAction(retryAction)

        return alert
    }()
    
    private lazy var nicknameTextField = setupTextField(for: .nickname)
    private lazy var descriptionTextField = setupTextField(for: .description)
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        navigationItem.setLeftBarButton(nil, animated: true)
        
        [avatarView,
         addPhotoButton,
         infoBlockView,
         nicknameLabel,
         descriptionLabel,
         nicknameTextField,
         descriptionTextField,
         editButton,
         stackView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        [nicknameLabel, descriptionLabel, nicknameTextField, descriptionTextField].forEach { infoBlockView.addArrangedSubview($0) }
        
        nicknameTextField.isHidden = true
        descriptionTextField.isHidden = true
        
        [avatarView, addPhotoButton, infoBlockView, editButton].forEach { stackView.addArrangedSubview($0) }
        
        view.addSubview(stackView)
        
        avatarView.isAccessibilityElement = true
        avatarView.accessibilityIdentifier = "Avatar"
        nicknameLabel.accessibilityIdentifier = "Nickname"
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.margin),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            avatarView.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            nicknameTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            descriptionTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            editButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: Constants.margin),
            editButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -Constants.margin),
            editButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Helpers
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func animateEditButton(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        
        let translation: CGFloat = 5
        let rotationAngle = CGFloat.pi * 0.1
        
        if !isButtonAnimated {
            self.editButton.transform = CGAffineTransform(rotationAngle: rotationAngle)
                .concatenating(CGAffineTransform(translationX: translation, y: translation))
        }
        
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [.repeat, .allowUserInteraction], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                self.editButton.transform = CGAffineTransform(rotationAngle: -rotationAngle)
                    .concatenating(CGAffineTransform(translationX: -translation, y: -translation))
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 1, animations: {
                self.editButton.transform = CGAffineTransform(rotationAngle: rotationAngle)
                    .concatenating(CGAffineTransform(translationX: translation, y: translation))
            })
        })
        
        if isButtonAnimated {
            UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState) {
                self.editButton.transform = CGAffineTransform.identity
            }
        }
        
        isButtonAnimated.toggle()
    }
    
    @objc private func switchToEditMode() {
        title = "Edit profile"
        
        navigationItem.setLeftBarButton(cancelButton, animated: true)
        navigationItem.setRightBarButton(nil, animated: true)

        nicknameTextField.isEnabled = true
        descriptionTextField.isEnabled = true
        
        nicknameTextField.becomeFirstResponder()
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1) {
            [self.nicknameLabel, self.descriptionLabel, self.editButton].forEach {
                $0.alpha = 0
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1) {
            [self.nicknameLabel, self.descriptionLabel, self.editButton].forEach {
                $0.isHidden = true
            }
            
            [self.nicknameTextField, self.descriptionTextField].forEach {
                $0.alpha = 1
                $0.isHidden = false
            }
            
            self.infoBlockView.spacing = 0
            self.view.backgroundColor = .secondarySystemBackground
        }
    }
    
    @objc private func cancelEditMode() {
        presenter.cancelSaving()
        
        nicknameTextField.text = currentUserData.nickname
        descriptionTextField.text = currentUserData.description
        
        title = "My profile"
        
        navigationItem.setLeftBarButton(nil, animated: true)
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1) {
            [self.nicknameTextField, self.descriptionTextField].forEach {
                $0.alpha = 0
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1) {
            [self.nicknameTextField, self.descriptionTextField].forEach {
                $0.isHidden = true
                $0.resignFirstResponder()
            }

            [self.nicknameLabel, self.descriptionLabel, self.editButton].forEach {
                $0.alpha = 1
                $0.isHidden = false
            }

            self.infoBlockView.spacing = 10
            self.view.backgroundColor = .systemBackground
        }
    }
    
    @objc private func saveData() {
        let user = UserProfileViewModel(
            nickname: nicknameTextField.text,
            description: descriptionTextField.text,
            image: avatarView.avatarImageView.image
        )
        
        presenter.saveUserData(user)
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
        if let name = model.nickname {
            nicknameLabel.text = name == "" ? "No name" : name
            nicknameTextField.text = name
            avatarView.configure(with: AvatarModel(size: Constants.avatarSize, nickname: name))
        }
        
        if let description = model.description {
            descriptionLabel.text = description == "" ? "No bio specified" : description
            descriptionTextField.text = description
        }
                
        if let avatar = model.image?.image {
            avatarView.setAvatarImage(image: avatar)
        }
    }
}

// MARK: - MVP extensions

extension ProfileViewController: ProfileViewInput {
    func setIsLoading() {
        navigationItem.setRightBarButton(activityIndicatorBarItem, animated: true)
        activityIndicator.startAnimating()
        nicknameTextField.isEnabled = false
        descriptionTextField.isEnabled = false
        addPhotoButton.isEnabled = false
    }
    
    func showData(_ user: UserProfileViewModel) {
        activityIndicator.stopAnimating()
        addPhotoButton.isEnabled = true
        currentUserData = user
        configure(with: user)
    }
    
    func showAlert(for type: AlertType) {
        switch type {
        case .success:
            present(successAlert, animated: true)
        case .error:
            present(errorAlert, animated: true)
        }
    }
}

extension ProfileViewController: ThemesServiceOutput {
    func setupTheme(_ theme: UIUserInterfaceStyle) {
        avatarActionSheet.overrideUserInterfaceStyle = theme
        successAlert.overrideUserInterfaceStyle = theme
        errorAlert.overrideUserInterfaceStyle = theme
    }
}

extension ProfileViewController: NetworkPhotosCollectionPresenterOutput {
    func setupAvatar(_ avatar: UIImage?) {
        dismiss(animated: true)
        
        guard let avatar else { return }
        
        avatarView.setAvatarImage(image: avatar)
        switchToEditMode()
        navigationItem.setRightBarButton(saveButton, animated: true)
    }
}

// MARK: - Delegates

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        dismiss(animated: true)
        
        guard let avatar = info[.editedImage] as? UIImage else { return }
        
        avatarView.setAvatarImage(image: avatar)
        switchToEditMode()
        navigationItem.setRightBarButton(saveButton, animated: true)
    }
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let needHideSaveButton =
            (nicknameTextField.text == currentUserData.nickname &&
             descriptionTextField.text == currentUserData.description &&
             avatarView.avatarImageView.image == currentUserData.image?.image) ||
            nicknameTextField.text == Optional("") ||
            descriptionTextField.text == Optional("")
        navigationItem.setRightBarButton(needHideSaveButton ? nil : saveButton, animated: true)
    }
}
