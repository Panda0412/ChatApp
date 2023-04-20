//
//  ChannelsDataSource.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 13.04.2023.
//

import Foundation

class ChannelsDataSource: ChannelsDataSourceProtocol {
    static let shared = ChannelsDataSource()
    
    private let coreDataService = CoreDataService()
    
    private init() {}
    
    func saveChannelItem(_ channel: ChannelItem) {
        coreDataService.save { context in
            let channelManagedObject = ChannelManagedObject(context: context)
            
            channelManagedObject.id = channel.id
            channelManagedObject.name = channel.name
            channelManagedObject.logoURL = channel.logoURL
            channelManagedObject.lastMessage = channel.lastMessage
            channelManagedObject.lastActivity = channel.lastActivity
            
            channelManagedObject.messages = NSOrderedSet()
        }
    }
    
    func saveMessageItem(_ message: MessageItem, in channelId: String) {
        coreDataService.save { context in
            let fetchRequest = ChannelManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", channelId)
            
            let channelManagedObject = try context.fetch(fetchRequest).first
            
            guard let channelManagedObject else { return }
                        
            let messageManagedObject = MessageManagedObject(context: context)
            
            messageManagedObject.id = message.id
            messageManagedObject.text = message.text
            messageManagedObject.userID = message.userID
            messageManagedObject.userName = message.userName
            messageManagedObject.date = message.date
            
            channelManagedObject.addToMessages(messageManagedObject)
        }
    }
    
    func getChannels() -> [ChannelItem] {
        do {
            let channelManagedObjects = try coreDataService.fetchChannels()
            
            let channels: [ChannelItem] = channelManagedObjects.compactMap { channelManagedObject in
                guard let id = channelManagedObject.id,
                      let name = channelManagedObject.name else {
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
            
            let sortedChannels = channels.sorted { channel, nextChannel in
                guard let channelDate = channel.lastActivity else {
                    return false
                }
                guard let nextChannelDate = nextChannel.lastActivity else {
                    return true
                }
                
                return channelDate > nextChannelDate
            }
            
            return sortedChannels
        } catch {
            print("getChannels error:", error)
            return []
        }
    }
    
    func getMessages(for channelId: String) -> [MessageItem] {
        do {
            let messagesManagedObjects = try coreDataService.fetchMessages(for: channelId)
            
            let messages: [MessageItem] = messagesManagedObjects.compactMap { messageManagedObject in
                guard let id = messageManagedObject.id,
                      let text = messageManagedObject.text,
                      let userID = messageManagedObject.userID,
                      let userName = messageManagedObject.userName,
                      let date = messageManagedObject.date else {
                    return nil
                }

                return MessageItem(
                    id: id,
                    text: text,
                    userID: userID,
                    userName: userName,
                    date: date
                )
            }

            return messages
        } catch {
            print("getMessages error:", error)
            return []
        }
    }
}
