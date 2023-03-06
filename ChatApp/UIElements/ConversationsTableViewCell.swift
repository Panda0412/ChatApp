//
//  ConversationsTableViewCell.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 05.03.2023.
//

import UIKit

private enum Constants {
    static let avatarSize: CGFloat = 45
    static let onlineIndicatorSize: CGFloat = 16
    static let padding: CGFloat = 16
    static let spacing: CGFloat = 12
    static let smallTextFontSize: CGFloat = 13
    static let mediumTextFontSize: CGFloat = 15
    static let largeTextFontSize: CGFloat = 17
}

class ConversationsTableViewCell: UITableViewCell, ConfigurableViewProtocol {
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    typealias ConfigurationModel = ConversationCellModel
    let dateFormatter = DateFormatter()

    // MARK: - UI Elements
    
    private lazy var avatarView = AvatarView()
    
    private lazy var onlineIndicator: UIView = {
        let indicatorView = UIView()
        let indicator = UIView()

        indicatorView.backgroundColor = .systemBackground
        indicator.backgroundColor = .systemGreen
        indicatorView.layer.cornerRadius = Constants.onlineIndicatorSize / 2
        indicator.layer.cornerRadius = (Constants.onlineIndicatorSize - 4) / 2
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        indicatorView.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicatorView.heightAnchor.constraint(equalToConstant: Constants.onlineIndicatorSize),
            indicatorView.widthAnchor.constraint(equalToConstant: Constants.onlineIndicatorSize),
            indicator.heightAnchor.constraint(equalToConstant: Constants.onlineIndicatorSize - 4),
            indicator.widthAnchor.constraint(equalToConstant: Constants.onlineIndicatorSize - 4),
            indicator.centerYAnchor.constraint(equalTo: indicatorView.centerYAnchor),
            indicator.centerXAnchor.constraint(equalTo: indicatorView.centerXAnchor)
        ])
        
        return indicatorView
    }()
    
    private lazy var messageBlockView: UIStackView = {
        let stack = UIStackView()
                
        stack.axis = .vertical
        stack.alignment = .leading
        
        return stack
    }()
    
    private lazy var nameLabel: UILabel = {
        let name = UILabel()
        
        name.font = UIFont.boldSystemFont(ofSize: Constants.largeTextFontSize)
        name.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        return name
    }()
    
    private lazy var messageLabel: UILabel = {
        let message = UILabel()
        
        message.numberOfLines = 2
        
        return message
    }()
    
    private lazy var dateLabel: UILabel = {
        let date = UILabel()
        
        date.font = .systemFont(ofSize: Constants.mediumTextFontSize)
        date.textColor = .secondaryLabel
        date.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        return date
    }()
    
    private lazy var disclosureIndicator: UIImageView = {
        let disclosureIndicator = UIImageView()
        
        let disclosureIndicatorConfig = UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: Constants.smallTextFontSize), scale: .small)
        disclosureIndicator.image = UIImage(systemName: "chevron.forward", withConfiguration: disclosureIndicatorConfig)
        disclosureIndicator.tintColor = .tertiaryLabel
        disclosureIndicator.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        return disclosureIndicator
    }()
    
    // MARK: - Setup
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        onlineIndicator.removeFromSuperview()
    }
    
    private func setupUI() {
        separatorInset = UIEdgeInsets(top: 0, left: Constants.padding + Constants.avatarSize + Constants.spacing, bottom: 0, right: 0)
                
        [avatarView,
         messageBlockView,
         nameLabel,
         messageLabel,
         dateLabel,
         disclosureIndicator].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        messageBlockView.addArrangedSubview(nameLabel)
        messageBlockView.addArrangedSubview(messageLabel)
        
        [avatarView, messageBlockView, dateLabel, disclosureIndicator].forEach {
            contentView.addSubview($0)
        }
                
        NSLayoutConstraint.activate([
            avatarView.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            
            messageBlockView.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor),
            messageBlockView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            messageBlockView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: Constants.spacing),
            messageBlockView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding),
            
            nameLabel.heightAnchor.constraint(equalToConstant: 22),
            
            dateLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: Constants.spacing),
            
            disclosureIndicator.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            disclosureIndicator.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: Constants.spacing),
            disclosureIndicator.trailingAnchor.constraint(equalTo: messageBlockView.trailingAnchor)
        ])
    }
    
    func configure(with model: ConversationCellModel) {
        avatarView.configure(with: AvatarModel(size: Constants.avatarSize, nickname: model.nickname))
        
        nameLabel.text = model.nickname
        
        if model.isOnline {
            avatarView.addSubview(onlineIndicator)
                    
            NSLayoutConstraint.activate([
                onlineIndicator.topAnchor.constraint(equalTo: avatarView.topAnchor, constant: -2),
                onlineIndicator.trailingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 2)
            ])
        }
        
        if let message = model.message {
            messageLabel.text = message
            messageLabel.font = model.hasUnreadMessages ? .boldSystemFont(ofSize: Constants.mediumTextFontSize) : .systemFont(ofSize: Constants.mediumTextFontSize)
            messageLabel.textColor = model.hasUnreadMessages ? .label : .secondaryLabel
        } else {
            messageLabel.text = "No messages yet"
            messageLabel.font = .italicSystemFont(ofSize: Constants.mediumTextFontSize)
            messageLabel.textColor = .secondaryLabel
        }
        
        dateFormatter.dateFormat = isDateToday(model.date) ? "HH:mm" : "dd MMM"
        dateLabel.text = dateFormatter.string(from: model.date)
    }
    
    // MARK: - Helpers
    
    private func isDateToday(_ date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date) == formatter.string(from: Date())
    }
}
