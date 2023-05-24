//
//  ChatServiceProtocolMock.swift
//  ChatAppUnitTests
//
//  Created by Anastasiia Bugaeva on 11.05.2023.
//

@testable import ChatApp
@testable import TFSChatTransport
import Combine

final class ChatServiceProtocolMock: ChatServiceProtocol {
    
    var invokedCreateChannel = false
    var invokedCreateChannelCount = 0
    var invokedCreateChannelParameters: (name: String, logoUrl: String?)?
    var invokedCreateChannelParametersList = [(name: String, logoUrl: String?)]()
    var stubbedCreateChannelResult: AnyPublisher<Channel, Error>!
    
    func createChannel(name: String, logoUrl: String?) -> AnyPublisher<Channel, Error> {
        invokedCreateChannel = true
        invokedCreateChannelCount += 1
        invokedCreateChannelParameters = (name, logoUrl)
        invokedCreateChannelParametersList.append((name, logoUrl))
        
        let channel = Channel(id: UUID().uuidString, name: name, logoURL: logoUrl, lastMessage: nil, lastActivity: nil)
        
        stubbedCreateChannelResult = Deferred {
            Future { promise in promise(.success(channel)) }
        }.eraseToAnyPublisher()
        
        return stubbedCreateChannelResult
    }

    var invokedLoadChannels = false
    var invokedLoadChannelsCount = 0
    var stubbedLoadChannelsResult: AnyPublisher<[Channel], Error>!

    func loadChannels() -> AnyPublisher<[Channel], Error> {
        invokedLoadChannels = true
        invokedLoadChannelsCount += 1
        
        let channels = [Channel]()
        
        stubbedLoadChannelsResult = Deferred {
            Future { promise in promise(.success(channels)) }
        }.eraseToAnyPublisher()
        
        return stubbedLoadChannelsResult
    }

    var invokedLoadChannel = false
    var invokedLoadChannelCount = 0
    var invokedLoadChannelParameters: (id: String, Void)?
    var invokedLoadChannelParametersList = [(id: String, Void)]()
    var stubbedLoadChannelResult: AnyPublisher<Channel, Error>!

    func loadChannel(id: String) -> AnyPublisher<Channel, Error> {
        invokedLoadChannel = true
        invokedLoadChannelCount += 1
        invokedLoadChannelParameters = (id, ())
        invokedLoadChannelParametersList.append((id, ()))
        
        let channel = Channel(id: id, name: "Loaded channel by id", logoURL: nil, lastMessage: nil, lastActivity: nil)
        
        stubbedLoadChannelResult = Deferred {
            Future { promise in promise(.success(channel)) }
        }.eraseToAnyPublisher()
        
        return stubbedLoadChannelResult
    }

    var invokedLoadMessages = false
    var invokedLoadMessagesCount = 0
    var invokedLoadMessagesParameters: (channelId: String, Void)?
    var invokedLoadMessagesParametersList = [(channelId: String, Void)]()
    var stubbedLoadMessagesResult: AnyPublisher<[Message], Error>!

    func loadMessages(channelId: String) -> AnyPublisher<[Message], Error> {
        invokedLoadMessages = true
        invokedLoadMessagesCount += 1
        invokedLoadMessagesParameters = (channelId, ())
        invokedLoadMessagesParametersList.append((channelId, ()))
        
        let messages = [Message]()
        
        stubbedLoadMessagesResult = Deferred {
            Future { promise in promise(.success(messages)) }
        }.eraseToAnyPublisher()
        
        return stubbedLoadMessagesResult
    }

    var invokedSendMessage = false
    var invokedSendMessageCount = 0
    var invokedSendMessageParameters: (text: String, channelId: String, userId: String, userName: String)?
    var invokedSendMessageParametersList = [(text: String, channelId: String, userId: String, userName: String)]()
    var stubbedSendMessageResult: AnyPublisher<Message, Error>!

    func sendMessage(text: String, channelId: String, userId: String, userName: String) -> AnyPublisher<Message, Error> {
        invokedSendMessage = true
        invokedSendMessageCount += 1
        invokedSendMessageParameters = (text, channelId, userId, userName)
        invokedSendMessageParametersList.append((text, channelId, userId, userName))
        
        let message = Message(id: UUID().uuidString, text: text, userID: userId, userName: userName, date: Date())
        
        stubbedSendMessageResult = Deferred {
            Future { promise in promise(.success(message)) }
        }.eraseToAnyPublisher()
        
        return stubbedSendMessageResult
    }
}
