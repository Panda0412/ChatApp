//
//  ChatModuleAssembly.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 18.04.2023.
//

import UIKit

final class ChatModuleAssembly {
    func makeChatModule(for channel: ChannelItem) -> UIViewController {
        let presenter = ChatPresenter(channelId: channel.id, channelService: ChannelService.shared, channelsDataSource: ChannelsDataSource.shared)
        let viewController = ChatViewController(output: presenter)
        
        viewController.title = channel.name
        presenter.viewInput = viewController
        
        return viewController
    }
}
