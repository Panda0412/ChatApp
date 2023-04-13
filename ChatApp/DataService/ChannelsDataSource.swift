//
//  ChannelsDataSource.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 13.04.2023.
//

import Foundation

class ChannelsDataSource {
    private let coreDataService = CoreDataService()
    
    func saveChannelItem(with channel: ChannelItem) {
        coreDataService.save { context in
            let channelManagedObject = ChannelManagedObject(context: context)
            
            channelManagedObject.id = channel.id
            channelManagedObject.name = channel.name
            channelManagedObject.logoURL = channel.logoURL
            channelManagedObject.lastMessage = channel.lastMessage
            channelManagedObject.lastActivity = channel.lastActivity
        }
    }
    
    func getChannels() -> [ChannelItem] {
        do {
            let channelManagedObjects = try coreDataService.getChannels()
            
            let channels: [ChannelItem] = channelManagedObjects.compactMap { channelManagedObject in
                guard
                    let id = channelManagedObject.id,
                    let name = channelManagedObject.name
                else {
                    return nil
                }
                
                return ChannelItem(
                    id: id,
                    name: name,
                    logoURL: channelManagedObject.logoURL,
                    lastMessage: channelManagedObject.lastMessage,
                    lastActivity: channelManagedObject.lastActivity
                )
            }
            
            return channels
        } catch {
            print(error)
            return []
        }
    }
}
