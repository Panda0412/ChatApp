//
//  AvatarView.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 05.03.2023.
//

import UIKit

class AvatarView: UIView {
    
    // MARK: - UI Elements
    
    private lazy var avatarView: UIView = {
        return UIView()
    }()
    
    private lazy var avatarGradient: CAGradientLayer = {
        let colorTop = CGColor(red: 0.95, green: 0.62, blue: 0.71, alpha: 1.00)
        let colorBottom = CGColor(red: 0.93, green: 0.48, blue: 0.58, alpha: 1.00)

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0, 1]
        
        return gradientLayer
    }()
    
    private func setupAvatarLabel(with nickname: String, fontSize: CGFloat) -> UILabel {
        let avatarLabel = UILabel()
        
        let nicknameArr = nickname.split(separator: " ").map{ $0.first ?? " " }
        avatarLabel.text = String(nicknameArr[0..<min(2, nicknameArr.count)])
        
        if let descriptor = UIFont.systemFont(ofSize: fontSize, weight: .bold).fontDescriptor.withDesign(.rounded) {
            avatarLabel.font = UIFont(descriptor: descriptor, size: fontSize)
        } else {
            avatarLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        }
        avatarLabel.textColor = .white
        
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false

        return avatarLabel
    }
    
    // MARK: - Helpers
    
    func configure(with model: AvatarModel) {
        avatarView.frame.size = CGSize(width: model.size, height: model.size)
        
        if let avatarImage = model.image {
            setAvatarImage(image: avatarImage)
        } else {
            avatarGradient.frame = avatarView.bounds
            avatarGradient.cornerRadius = model.size / 2
            
            let avatarLabel = setupAvatarLabel(with: model.nickname, fontSize: CGFloat(model.size / 3))
                        
            avatarView.layer.addSublayer(avatarGradient)
            avatarView.addSubview(avatarLabel)

            NSLayoutConstraint.activate([
                avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
                avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor)
            ])
        }
        
        addSubview(avatarView)
    }
    
    func setAvatarImage(image: UIImage) {
        let avatarImageView = UIImageView()
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = Double(avatarView.frame.height) / 2
        avatarImageView.layer.masksToBounds = true
        
        avatarImageView.image = image
        
        avatarView.subviews.forEach({ $0.removeFromSuperview() })
        avatarView.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: avatarView.frame.height),
            avatarImageView.widthAnchor.constraint(equalToConstant: avatarView.frame.height)
        ])
    }
}

// MARK: - Model

struct AvatarModel {
    let size: Double
    let nickname: String
    let image: UIImage?
    
    init(size: Double, nickname: String, image: UIImage? = nil) {
        self.size = size
        self.nickname = nickname
        self.image = image
    }
}
