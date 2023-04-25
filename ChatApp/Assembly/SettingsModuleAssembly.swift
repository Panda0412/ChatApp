//
//  SettingsModuleAssembly.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 18.04.2023.
//

import UIKit

final class SettingsModuleAssembly {
    
    private let themesService: ThemesService

    init(themesService: ThemesService) {
        self.themesService = themesService
    }
    
    func makeSettingsModule() -> UIViewController {
        let viewController = SettingsViewController(themesService: themesService)
        themesService.settingsModule = viewController
        
        return viewController
    }

}
