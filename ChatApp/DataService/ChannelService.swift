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
    private lazy var chatService = ChatService(host: "167.235.86.234", port: 8080)
    private var request: Cancellable?
    
    func getChannels(completion: @escaping (Result<[ChannelItem], Error>) -> Void) {
        request = chatService.loadChannels()
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
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
}
