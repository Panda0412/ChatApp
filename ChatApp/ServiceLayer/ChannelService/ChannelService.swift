//
//  ChannelService.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 12.04.2023.
//

import UIKit
import Combine
import TFSChatTransport

class ChannelService: ChannelServiceProtocol {
    static let shared = ChannelService(chatService: ChatService(host: "167.235.86.234", port: 8080))
    
    private let chatService: ChatServiceProtocol
    private let sseService = SSEService(host: "167.235.86.234", port: 8080)
    private let combineService: CombineServiceProtocol
    private let backgroundQueue = DispatchQueue.global(qos: .userInitiated)
    private let defaults = UserDefaults.standard

    private var channelsRequest: Cancellable?
    private var channelMessagesRequest: Cancellable?
    private var createChannelRequest: Cancellable?
    private var sendMessagesRequest: Cancellable?
    private var userDataRequest: Cancellable?
    private var sseRequest: Cancellable?
    private var channelInfoRequest: Cancellable?

    private var userName: String?
    var userId: String
    
    init(chatService: ChatServiceProtocol) {
        self.chatService = chatService
        
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
        createChannelRequest = chatService.createChannel(name: channelName, logoUrl: nil)
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
    
    func subscribe(completion: @escaping (Result<ChannelEvent, ChannelServiceError>) -> Void) {
        sseRequest = sseService.subscribeOnEvents()
            .sink(receiveCompletion: { _ in
                completion(.failure(ChannelServiceError.sseLostConnection))
            }, receiveValue: { event in                
                switch event.eventType {
                case .add: fallthrough
                case .update:
                    self.getInfoForChannel(with: event.resourceID) { result in
                        switch result {
                        case .success(let channel):
                                completion(.success(ChannelEvent(eventType: event.eventType, channelID: event.resourceID, channel: channel)))
                        case .failure(_):
                            completion(.failure(ChannelServiceError.loadChannelInfoError))
                        }
                    }
                case .delete:
                    completion(.success(ChannelEvent(eventType: event.eventType, channelID: event.resourceID, channel: nil)))
            }
            })
    }
    
    func getInfoForChannel(with id: String, completion: @escaping (Result<ChannelItem, Error>) -> Void) {
        channelInfoRequest = chatService.loadChannel(id: id)
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
}
