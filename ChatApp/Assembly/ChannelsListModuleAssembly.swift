//
//  ChannelsListModuleAssembly.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 18.04.2023.
//

import UIKit

final class ChannelsListModuleAssembly {
    
    private let themesService: ThemesService

    init(themesService: ThemesService) {
        self.themesService = themesService
    }
    
    func makeChannelsListModule() -> UIViewController {
        let presenter = ChannelsListPresenter()
        let viewController = ChannelsListViewController(output: presenter, themesService: themesService)
        
        presenter.viewInput = viewController
        themesService.channelsListModule = viewController
        
        return viewController
    }
}
