//
//  MessageItem.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.04.2023.
//

import TFSChatTransport

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
