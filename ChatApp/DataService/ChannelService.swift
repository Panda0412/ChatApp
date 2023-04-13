//
//  ChatService.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 12.04.2023.
//

import UIKit
import Combine
import TFSChatTransport

class ChannelService {
    private let chatService = ChatService(host: "167.235.86.234", port: 8080)
    private var channelsRequest: Cancellable?
    private var channelMessagesRequest: Cancellable?
    private let backgroundQueue = DispatchQueue.global(qos: .userInitiated)
    
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
}
