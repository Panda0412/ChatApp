//
//  ChatServiceProtocol.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 11.05.2023.
//

import Combine
import TFSChatTransport

protocol ChatServiceProtocol {
    func createChannel(name: String, logoUrl: String?) -> AnyPublisher<Channel, Error>
    func loadChannels() -> AnyPublisher<[Channel], Error>
    func loadChannel(id: String) -> AnyPublisher<Channel, Error>
    func loadMessages(channelId: String) -> AnyPublisher<[Message], Error>
    func sendMessage(text: String, channelId: String, userId: String, userName: String) -> AnyPublisher<Message, Error>
}

extension ChatService: ChatServiceProtocol {}
