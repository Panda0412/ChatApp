//
//  ChannelServiceTests.swift
//  ChatAppUnitTests
//
//  Created by Anastasiia Bugaeva on 11.05.2023.
//

import XCTest
@testable import ChatApp

final class ChannelServiceTests: XCTestCase {
    
    // MARK: - Setup
    
    var chatService: ChatServiceProtocolMock!
    var channelService: ChannelService!
    
    override func setUp() {
        chatService = ChatServiceProtocolMock()
        channelService = ChannelService(chatService: chatService)
    }
    
    override func tearDown() {
        chatService = nil
        channelService = nil
    }
    
    // MARK: - Tests
    
    func testGetChannels() {
        // Act
        channelService.getChannels { _ in return }
        
        // Assert
        XCTAssertEqual(chatService.invokedLoadChannelsCount, 1)
    }
    
    func testGetChannelMessages() {
        // Arrange
        let channelId = UUID().uuidString
        
        // Act
        channelService.getChannelMessages(for: channelId) { _ in return }
        
        // Assert
        XCTAssertEqual(chatService.invokedLoadMessagesCount, 1)
        XCTAssertEqual(chatService.invokedLoadMessagesParameters?.channelId, channelId)
    }
    
    func testCreateChannel() {
        // Arrange
        let expectation = XCTestExpectation(description: "testCreateChannel")
        let channelName = "testCreateChannel"
        var createdChannel: ChannelItem? = nil
        
        // Act
        channelService.createChannel(channelName) { result in
            switch result {
                case .success(let channel):
                    createdChannel = channel
                    expectation.fulfill()
                case .failure: break
            }
        }
        
        // Assert
        XCTAssertEqual(chatService.invokedCreateChannelCount, 1)
        XCTAssertEqual(chatService.invokedCreateChannelParameters?.name, channelName)
        wait(for: [expectation], timeout: 0.3)
        XCTAssertEqual(createdChannel?.name, channelName)
    }
    
    func testGetInfoForChannel() {
        // Arrange
        let expectation = XCTestExpectation(description: "testGetInfoForChannel")
        let channelId = UUID().uuidString
        var loadedChannel: ChannelItem? = nil
        
        // Act
        channelService.getInfoForChannel(with: channelId) { result in
            switch result {
                case .success(let channel):
                    loadedChannel = channel
                    expectation.fulfill()
                case .failure: break
            }
        }
        
        // Assert
        XCTAssertEqual(chatService.invokedLoadChannelCount, 1)
        XCTAssertEqual(chatService.invokedLoadChannelParameters?.id, channelId)
        wait(for: [expectation], timeout: 0.3)
        XCTAssertEqual(loadedChannel?.id, channelId)
    }

}
