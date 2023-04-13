//
//  models.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 06.03.2023.
//

import UIKit
import TFSChatTransport

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

// MARK: - Channels Table

enum ChannelSections: Hashable, CaseIterable {
    case all
}

struct ChannelItem: Hashable {
    let id: String
    let name: String
    let logoURL: String?
    let lastMessage: String?
    let lastActivity: Date?
    
    init(id: String, name: String, logoURL: String?, lastMessage: String?, lastActivity: Date?) {
        self.id = id
        self.name = name
        self.logoURL = logoURL
        self.lastMessage = lastMessage
        self.lastActivity = lastActivity
    }
    
    init(from channel: Channel) {
        self.id = channel.id
        self.name = channel.name
        self.logoURL = channel.logoURL
        self.lastMessage = channel.lastMessage
        self.lastActivity = channel.lastActivity
    }
}

struct ChannelCellModel {
    let nickname: String
    let message: String?
    let date: Date?
}

// MARK: - Chat Table

struct MessageSection: Hashable {
    let date: Date
    let messages: [MessageItem]
}

public struct MessageItem: Hashable {
    let id: String
    let text: String
    let userID: String
    let userName: String
    let date: Date
    var isBubbleTailNeeded: Bool = false
    var isNicknameNeeded: Bool = false

    init(id: String, text: String, userID: String, userName: String, date: Date) {
        self.id = id
        self.text = text
        self.userID = userID
        self.userName = userName
        self.date = date
    }
    
    init(from message: Message) {
        self.id = message.id
        self.text = message.text
        self.userID = message.userID
        self.userName = message.userName
        self.date = message.date
    }
}

struct MessageCellModel {
    let userName: String
    let message: String
    let date: Date
    let isIncoming: Bool
    var isBubbleTailNeeded: Bool
    var isNicknameNeeded: Bool
}
