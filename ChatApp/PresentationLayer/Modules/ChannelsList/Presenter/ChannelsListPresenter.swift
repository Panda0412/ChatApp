//
//  ChannelsListPresenter.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 18.04.2023.
//

import Foundation

final class ChannelsListPresenter {
    
    weak var viewInput: ChannelsListViewInput?
    private var channels = [ChannelItem]()
    private var coreDataChannels = ChannelsDataSource.shared.getChannels()
    
    private func fetchChannels() {
        ChannelService.shared.getChannels { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let channels):
                self.channels = channels
                self.viewInput?.showData(channels)
                self.saveChannelsToCoreData(channels)
            case .failure(_):
                self.viewInput?.showData(self.coreDataChannels)
                self.viewInput?.showAlert()
            }
            
            self.viewInput?.endRefresh()
        }
    }
    
    private func saveChannelsToCoreData(_ channels: [ChannelItem]) {
        for channel in channels {
            guard coreDataChannels.contains(channel) else {
                coreDataChannels.append(channel)
                ChannelsDataSource.shared.saveChannelItem(channel)
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
        guard channels.indices.contains(index) else { return }
        
        let chatScreen = ChatModuleAssembly().makeChatModule(for: channels[index])
        
        viewInput?.navigationController?.pushViewController(chatScreen, animated: true)
    }
    
    func createChannel(_ channelName: String?) {
        guard let channelName = channelName else { return }
        
        ChannelService.shared.createChannel(channelName) { [weak self] result in
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
