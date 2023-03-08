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
    let nickname: String
    let image: UIImage?
    
    init(size: Double, nickname: String, image: UIImage? = nil) {
        self.size = size
        self.nickname = nickname
        self.image = image
    }
}

// MARK: - Conversations Table

enum ConversationSections: Hashable, CaseIterable {
    case online
    case history
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
