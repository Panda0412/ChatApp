//
//  ChatEvent.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 28.04.2023.
//

import TFSChatTransport

struct ChannelEvent {
    public let eventType: ChatEvent.EventType
    public let channelID: String
    public let channel: ChannelItem?
}
