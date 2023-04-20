//
//  ChatPresenter.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 18.04.2023.
//

import Foundation

final class ChatPresenter {
    
    weak var viewInput: ChatViewInput?
    private var channelId: String
    
    private var coreDataMessages = [MessageItem]()
    private var coreDataSections = [MessageSection]()
    private var networkSections = [MessageSection]()
    
    init(channelId: String) {
        self.channelId = channelId
        coreDataMessages = ChannelsDataSource.shared.getMessages(for: channelId)
        coreDataSections = makeSections(from: coreDataMessages)
    }
    
    private func makeSections(from messages: [MessageItem]) -> [MessageSection] {
        if messages.isEmpty { return [] }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        
        var sections: [MessageSection] = []
        var currentSectionDate = messages[0].date
        var currentSectionMessages: [MessageItem] = []
        
        for (index, message) in messages.enumerated() {
            let prevMessage = index != 0 ? messages[index - 1] : nil
            var currentMessage = message
            let nextMessage = index != messages.count - 1 ? messages[index + 1] : nil
            
            let isIncoming = currentMessage.userID != ChannelService.shared.userId
            
            if let prevMessage = prevMessage,
                currentMessage.userID != prevMessage.userID ||
                formatter.string(from: currentSectionDate) != formatter.string(from: prevMessage.date) {
                currentMessage.isNicknameNeeded = isIncoming
            } else if prevMessage == nil {
                currentMessage.isNicknameNeeded = isIncoming
            }
            if let nextMessage = nextMessage,
                currentMessage.userID != nextMessage.userID ||
                formatter.string(from: currentSectionDate) != formatter.string(from: nextMessage.date) {
                currentMessage.isBubbleTailNeeded = true
            } else if nextMessage == nil {
                currentMessage.isBubbleTailNeeded = true
            }
            
            if formatter.string(from: currentMessage.date) == formatter.string(from: currentSectionDate) {
                currentSectionMessages.append(currentMessage)
            } else {
                if !currentSectionMessages.isEmpty {
                    sections.append(MessageSection(date: currentSectionDate, messages: currentSectionMessages))
                }
                currentMessage.isNicknameNeeded = isIncoming
                currentSectionDate = currentMessage.date
                currentSectionMessages = [currentMessage]
            }
        }
        
        sections.append(MessageSection(date: currentSectionDate, messages: currentSectionMessages))
        
        return sections
    }
    
    private func fetchMessages() {
        ChannelService.shared.getChannelMessages(for: channelId) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let messages):
                self.networkSections = self.makeSections(from: messages)
//                self.setupDataSource(with: self.chatSections)
                self.viewInput?.showData(self.networkSections, animated: false)
                self.saveMessagesToCoreData(messages)
            case .failure(_):
                self.viewInput?.showData(self.coreDataSections, animated: false)
                self.viewInput?.showAlert()
//                self.setupDataSource(with: self.coreDataSections)
//                self.present(self.errorAlert, animated: true)
            }
        }
    }
    
    private func saveMessagesToCoreData(_ messages: [MessageItem]) {
        for message in messages {
            guard coreDataMessages.contains(message) else {
                coreDataMessages.append(message)
                ChannelsDataSource.shared.saveMessageItem(message, in: channelId)
                continue
            }
        }
        
        coreDataSections = makeSections(from: coreDataMessages)
    }
    
    private func send(messageText: String) {
        ChannelService.shared.sendMessage(messageText, for: channelId) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(var message):
                self.viewInput?.clearTextField()
                    
                message.isBubbleTailNeeded = true
                
                ChannelsDataSource.shared.saveMessageItem(message, in: self.channelId)
                self.coreDataMessages.append(message)
                self.coreDataSections = self.makeSections(from: self.coreDataMessages)
                
                let lastSectionIndex = self.networkSections.count - 1
                
                guard lastSectionIndex != -1 else {
                    self.networkSections.append(MessageSection(date: message.date, messages: [message]))
                    self.viewInput?.showData(self.networkSections, animated: true)
                    return
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMM yyyy"
                
                let lastMessageIndex = self.networkSections[lastSectionIndex].messages.count - 1
                
                if self.networkSections[lastSectionIndex].messages[lastMessageIndex].userID == message.userID {
                    self.networkSections[lastSectionIndex].messages[lastMessageIndex].isBubbleTailNeeded = false
                }
                
                if formatter.string(from: self.networkSections[lastSectionIndex].date) == formatter.string(from: message.date) {
                    self.networkSections[lastSectionIndex].messages.append(message)
                } else {
                    self.networkSections.append(MessageSection(date: message.date, messages: [message]))
                }
                
                self.viewInput?.showData(self.networkSections, animated: true)
            case .failure(_):
                self.viewInput?.showAlert()
            }
        }
    }
}

extension ChatPresenter: ChatViewOutput {
    func viewIsReady() {
        fetchMessages()
    }
    
    func sendMessage(_ message: String) {
        send(messageText: message)
    }
}
