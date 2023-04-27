//
//  ChatService.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 12.04.2023.
//

import UIKit
import Combine
import TFSChatTransport

class ChannelService: ChannelServiceProtocol {
    static let shared = ChannelService()
    
    private let chatService = ChatService(host: "167.235.86.234", port: 8080)
    private let combineService: CombineServiceProtocol
    private let backgroundQueue = DispatchQueue.global(qos: .userInitiated)
    private let defaults = UserDefaults.standard

    private var channelsRequest: Cancellable?
    private var channelMessagesRequest: Cancellable?
    private var createChannelRequest: Cancellable?
    private var sendMessagesRequest: Cancellable?
    private var userDataRequest: Cancellable?
    
    private var userName: String?
    var userId: String
    
    private init() {
        if let id = defaults.string(forKey: "userId") {
            userId = id
        } else {
            userId = UUID().uuidString
            defaults.set(userId, forKey: "userId")
        }
        
        self.combineService = CombineService.shared
        
        getUserName()
    }
    
    private func getUserName() {
        userDataRequest = combineService.getProfileDataPublisher
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
                    if let channelDate = channel.lastActivity, let nextChannelDate = nextChannel.lastActivity {
                        return channelDate > nextChannelDate
                    }

                    return channel.lastActivity != nil
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
    
    func createChannel(_ channelName: String, completion: @escaping (Result<ChannelItem, Error>) -> Void) {
        createChannelRequest = chatService.createChannel(name: channelName)
            .subscribe(on: backgroundQueue)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: break
                case .failure(let error):
                    completion(.failure(error))
                }
            }, receiveValue: { channel in
                completion(.success(ChannelItem(from: channel)))
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
