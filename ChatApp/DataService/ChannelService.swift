//
//  ChatService.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 12.04.2023.
//

import UIKit
import Combine
import TFSChatTransport

public enum ChannelServiceError: Error {
    case userNameError
}

class ChannelService {
    private let chatService = ChatService(host: "167.235.86.234", port: 8080)
    private let backgroundQueue = DispatchQueue.global(qos: .userInitiated)
    private let defaults = UserDefaults.standard

    private var channelsRequest: Cancellable?
    private var channelMessagesRequest: Cancellable?
    private var sendMessagesRequest: Cancellable?
    private var userDataRequest: Cancellable?
    
    private var userName: String?
    var userId: String
    
    init() {
        if let id = defaults.string(forKey: "userId") {
            userId = id
        } else {
            userId = UUID().uuidString
            defaults.set(userId, forKey: "userId")
        }
        
        getUserName()
    }
    
    private func getUserName() {
        self.userDataRequest = sharedCombineService.getProfileDataPublisher
            .map { $0.nickname ?? "" }
            .assign(to: \.userName, on: self)
    }
    
    func getChannels(completion: @escaping (Result<[ChannelItem], Error>) -> Void) {
        channelsRequest = chatService.loadChannels()
            .subscribe(on: backgroundQueue)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: break
                case .failure(let error):
                    completion(.failure(error))
                }
            }, receiveValue: { channels in
                let sortedChannels = channels.sorted { channel, nextChannel in
                    guard let channelDate = channel.lastActivity else {
                        return false
                    }
                    guard let nextChannelDate = nextChannel.lastActivity else {
                        return true
                    }
                    
                    return channelDate > nextChannelDate
                }
                
                completion(.success(sortedChannels.map { ChannelItem(from: $0) }))
            })
    }
    
    func getChannelMessages(for channelId: String, completion: @escaping (Result<[MessageItem], Error>) -> Void) {
        channelMessagesRequest = chatService.loadMessages(channelId: channelId)
            .subscribe(on: backgroundQueue)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: break
                case .failure(let error):
                    completion(.failure(error))
                }
            }, receiveValue: { messages in
                let sortedMessages = messages.sorted { message, nextMessage in
                    return message.date < nextMessage.date
                }
                
                completion(.success(sortedMessages.map { MessageItem(from: $0) }))
            })
    }
    
    func sendMessage(_ message: String, for channelId: String, completion: @escaping (Result<MessageItem, Error>) -> Void) {
        guard let userName = userName else {
            completion(.failure(ChannelServiceError.userNameError))
            return
        }

        sendMessagesRequest = chatService.sendMessage(text: message, channelId: channelId, userId: userId, userName: userName)
            .subscribe(on: backgroundQueue)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: break
                case .failure(let error):
                    completion(.failure(error))
                }
            }, receiveValue: { message in
                completion(.success(MessageItem(from: message)))
            })
    }
}

let sharedChannelService = ChannelService()
