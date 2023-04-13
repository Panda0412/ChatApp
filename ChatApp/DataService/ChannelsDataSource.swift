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
            channelManagedObject.lastMessage = channel.lastMessage
            channelManagedObject.lastActivity = channel.lastActivity

//            channelManagedObject.images = NSOrderedSet()
        }
    }
    
    func getChannels() -> [ChannelItem] {
        do {
            let channelManagedObjects = try coreDataService.getChannels()
            
            let channels: [ChannelItem] = channelManagedObjects.compactMap { channelManagedObject in
                guard
                    let id = channelManagedObject.id,
                    let name = channelManagedObject.name,
                    let lastMessage = channelManagedObject.lastMessage,
                    let lastActivity = channelManagedObject.lastActivity
                else {
                    return nil
                }
                
                return ChannelItem(id: id, name: name, logoURL: nil, lastMessage: lastMessage, lastActivity: lastActivity)
            }
            
            return channels
        } catch {
            print(error)
            return []
        }
    }
}
