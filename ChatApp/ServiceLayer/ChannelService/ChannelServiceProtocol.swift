//
//  ChannelServiceProtocol.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.04.2023.
//

import Foundation

protocol ChannelServiceProtocol {
    var userId: String { get }
    func getChannels(completion: @escaping (Result<[ChannelItem], Error>) -> Void)
    func getChannelMessages(for channelId: String, completion: @escaping (Result<[MessageItem], Error>) -> Void)
    func createChannel(_ channelName: String, completion: @escaping (Result<ChannelItem, Error>) -> Void)
    func sendMessage(_ message: String, for channelId: String, completion: @escaping (Result<MessageItem, Error>) -> Void)
}
