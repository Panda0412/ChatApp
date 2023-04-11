//
//  models.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 06.03.2023.
//

import UIKit

// MARK: - Avatar

struct AvatarModel {
    let size: Double
    let nickname: String?
    let image: UIImage?
    
    init(size: Double, nickname: String? = nil, image: UIImage? = nil) {
        self.size = size
        self.nickname = nickname
        self.image = image
    }
}

// MARK: - Profile View

struct AvatarImage: Codable {
    let image: UIImage?
    
    init(image: UIImage?) {
        self.image = image
    }
    
    enum CodingKeys: CodingKey { case data }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let data = try? container.decode(Data.self, forKey: .data) {
            self.image = UIImage(data: data)
        } else {
            self.image = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let image = self.image {
            try container.encode(image.pngData(), forKey: .data)
        }
    }
}

struct UserProfileViewModel: Codable {
    let nickname: String?
    let description: String?
    let image: AvatarImage?
    
    init(nickname: String? = nil, description: String? = nil, image: UIImage? = nil) {
        self.nickname = nickname
        self.description = description
        self.image = AvatarImage(image: image)
    }
}

// MARK: - Conversations Table

enum ConversationSections: Hashable, CaseIterable {
    case all
}

struct ConversationItem: Hashable {
    let id = UUID()
    let nickname: String
    let message: String?
    let date: Date
    let isOnline: Bool
    let hasUnreadMessages: Bool
}

struct ConversationCellModel {
    let nickname: String
    let message: String?
    let date: Date
    let isOnline: Bool
    let hasUnreadMessages: Bool
}

// MARK: - Chat Table

struct MessageSection: Hashable {
    let date: Date
    let messages: [MessageItem]
}

struct MessageItem: Hashable {
    let id = UUID()
    let message: String
    let date: Date
    let isIncoming: Bool
}

struct MessageCellModel {
    let message: String
    let date: Date
    let isIncoming: Bool
}
