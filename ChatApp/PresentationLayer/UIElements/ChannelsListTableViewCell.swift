//
//  ChannelsListTableViewCell.swift
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

class ChannelsListTableViewCell: UITableViewCell, ConfigurableViewProtocol {
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let dateFormatter = DateFormatter()

    // MARK: - UI Elements
    
    private lazy var avatarView = AvatarView()
    
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
    }
    
    private func setupUI() {
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
    
    func configure(with model: ChannelCellModel) {
        avatarView.configure(with: AvatarModel(size: Constants.avatarSize, nickname: model.nickname))
        
        nameLabel.text = model.nickname
        
        if let message = model.message, message != "" {
            messageLabel.text = message
            messageLabel.font = .systemFont(ofSize: Constants.mediumTextFontSize)
            messageLabel.textColor = .secondaryLabel
        } else {
            messageLabel.text = model.message == "" ? "Empty message" : "No messages yet"
            messageLabel.font = .italicSystemFont(ofSize: Constants.mediumTextFontSize)
            messageLabel.textColor = .secondaryLabel
        }
        
        if let date = model.date {
            dateFormatter.dateFormat = isDateToday(date) ? "HH:mm" : "dd MMM"
            dateLabel.text = dateFormatter.string(from: date)
        } else {
            dateLabel.text = ""
        }
    }
    
    // MARK: - Helpers
    
    private func isDateToday(_ date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date) == formatter.string(from: Date())
    }
}
