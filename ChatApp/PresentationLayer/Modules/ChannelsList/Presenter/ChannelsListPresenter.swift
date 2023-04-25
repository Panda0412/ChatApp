//
//  ChannelsListPresenter.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 18.04.2023.
//

import Foundation

final class ChannelsListPresenter {
    
    weak var viewInput: ChannelsListViewInput?
    private let channelService: ChannelServiceProtocol
    private let channelsDataSource: ChannelsDataSourceProtocol
    private var channels = [ChannelItem]()
    private var coreDataChannels: [ChannelItem]
    private var needCleanCoreData = true
    private var needShowAlert = true
    
    init(channelService: ChannelServiceProtocol, channelsDataSource: ChannelsDataSourceProtocol) {
        self.channelService = channelService
        self.channelsDataSource = channelsDataSource
        coreDataChannels = channelsDataSource.getChannels()
    }
    
    private func fetchChannels() {
        channelService.getChannels { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let channels):
                self.channels = channels
                self.viewInput?.showData(channels)
                self.viewInput?.setPrompt(nil)
                if self.needCleanCoreData {
                    self.channelsDataSource.cleanData()
                    self.coreDataChannels = self.channelsDataSource.getChannels()
                    self.needCleanCoreData = false
                }
                self.saveChannelsToCoreData(channels)
            case .failure(_):
                self.viewInput?.showData(self.coreDataChannels)
                if self.needShowAlert {
                    self.viewInput?.showAlert()
                    self.needShowAlert = false
                }
                self.viewInput?.setPrompt("No internet connection")
            }
            
            self.viewInput?.endRefresh()
        }
    }
    
    private func saveChannelsToCoreData(_ channels: [ChannelItem]) {
        for channel in channels {
            guard coreDataChannels.contains(channel) else {
                coreDataChannels.append(channel)
                channelsDataSource.saveChannelItem(channel)
                continue
            }
        }
    }
}

extension ChannelsListPresenter: ChannelsListViewOutput {
    func viewIsReady() {
        viewInput?.showData(coreDataChannels)
        fetchChannels()
    }
    
    func reloadData() {
        fetchChannels()
    }
    
    func didSelectItem(at index: Int) {
        var selectedChannel: ChannelItem
        
        if channels.indices.contains(index) {
            selectedChannel = channels[index]
        } else if coreDataChannels.indices.contains(index) {
            selectedChannel = coreDataChannels[index]
        } else { return }
        
        let chatScreen = ChatModuleAssembly().makeChatModule(for: selectedChannel)
        
        viewInput?.navigationController?.pushViewController(chatScreen, animated: true)
    }
    
    func createChannel(_ channelName: String?) {
        guard let channelName = channelName else { return }
        
        channelService.createChannel(channelName) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(_):
                self.fetchChannels()
            case .failure(_):
                self.viewInput?.showAlert()
            }
        }
    }
}
