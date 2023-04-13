//
//  ChatTableViewCell.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 08.03.2023.
//

import UIKit

private enum Constants {
    static let verticalPadding: CGFloat = 6
    static let horizontalPadding: CGFloat = 12
    static let margin: CGFloat = 20
    static let spacing: CGFloat = 8
}

class ChatTableViewCell: UITableViewCell, ConfigurableViewProtocol {
    
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
    
    private lazy var messageAuthorLabel: UILabel = {
        let nickname = UILabel()
        
        nickname.font = .systemFont(ofSize: 11)
        nickname.textColor = .secondaryLabel
        nickname.translatesAutoresizingMaskIntoConstraints = false
        
        return nickname
    }()
    
    private lazy var messageView: UIView = {
        let messageView = UIView()
        
        messageView.layer.cornerRadius = 17
        
        return messageView
    }()
    
    private lazy var messageText: UILabel = {
        let messageText = UILabel()
        
        messageText.numberOfLines = 0
        messageText.font = .systemFont(ofSize: 17)
        messageText.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return messageText
    }()
    
    private lazy var timeLabel: UILabel = {
        let time = UILabel()
        
        time.font = .systemFont(ofSize: 11)
        time.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        return time
    }()
    
    private lazy var rightTail: UIImageView = {
        let tail = UIImageView()
        
        let tailImage = UIImage(named: "bubble_tail")
        tail.image = tailImage?.withRenderingMode(.alwaysTemplate)
        tail.tintColor = UIColor(red: 0.27, green: 0.54, blue: 0.97, alpha: 1)
        
        return tail
    }()
    
    private lazy var leftTail: UIImageView = {
        let tail = UIImageView()
        
        let tailImage = UIImage(named: "bubble_tail")
        tail.image = tailImage?.withRenderingMode(.alwaysTemplate).withHorizontallyFlippedOrientation()
        tail.tintColor = .systemGray5
        
        return tail
    }()
    
    // MARK: - Setup
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        messageAuthorLabel.removeFromSuperview()
        messageView.removeFromSuperview()
        rightTail.removeFromSuperview()
        leftTail.removeFromSuperview()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .systemBackground

        [messageText, timeLabel, messageView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        messageView.addSubview(messageText)
        messageView.addSubview(timeLabel)

        NSLayoutConstraint.activate([
//            messageText.heightAnchor.constraint(greaterThanOrEqualToConstant: 22),
            messageText.topAnchor.constraint(equalTo: messageView.topAnchor, constant: Constants.verticalPadding),
            messageText.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: Constants.horizontalPadding),
            messageText.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -Constants.verticalPadding),
            messageText.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -Constants.verticalPadding),
            
            timeLabel.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -Constants.horizontalPadding),
            timeLabel.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -Constants.verticalPadding)
        ])
    }
    
    func configure(with model: MessageCellModel) {
        messageText.text = model.message
        messageText.textColor = model.isIncoming ? .label : .white
        
        dateFormatter.dateFormat = "HH:mm"
        timeLabel.text = dateFormatter.string(from: model.date)
        timeLabel.textColor = model.isIncoming ? .secondaryLabel : .init(white: 1, alpha: 0.6)
        
        contentView.addSubview(messageView)

        messageView.backgroundColor = model.isIncoming ? .systemGray5 : UIColor(red: 0.27, green: 0.54, blue: 0.97, alpha: 1)
        
        if model.isNicknameNeeded {
            messageAuthorLabel.text = model.userName
            
            contentView.addSubview(messageAuthorLabel)
            
            NSLayoutConstraint.activate([
                messageAuthorLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
                messageAuthorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 35)
            ])
        }
        
        if model.isBubbleTailNeeded {
            let tail = model.isIncoming ? leftTail : rightTail
            tail.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(tail)
            
            NSLayoutConstraint.activate([
                model.isIncoming ?
                    tail.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -4) :
                    tail.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: 4),
                tail.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -1),
                tail.heightAnchor.constraint(equalToConstant: 20.5),
                tail.widthAnchor.constraint(equalToConstant: 16.5)
            ])
        }
        
        NSLayoutConstraint.activate([
            model.isIncoming ?
                messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.margin) :
                messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.margin),
            model.isNicknameNeeded ?
                messageView.topAnchor.constraint(equalTo: messageAuthorLabel.bottomAnchor, constant: Constants.spacing / 2) :
                messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.spacing),
            messageView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 3 / 4, constant: -Constants.margin),
            messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
