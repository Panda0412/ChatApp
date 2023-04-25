//
//  ChannelsDataSourceProtocol.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.04.2023.
//

import Foundation

protocol ChannelsDataSourceProtocol {
    func saveChannelItem(_ channel: ChannelItem)
    func saveMessageItem(_ message: MessageItem, in channelId: String)
    func getChannels() -> [ChannelItem]
    func getMessages(for channelId: String) -> [MessageItem]
}
