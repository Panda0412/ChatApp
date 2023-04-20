//
//  ProfileModuleAssembly.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 18.04.2023.
//

import UIKit

final class ProfileModuleAssembly {
    
    private let themesService: ThemesService

    init(themesService: ThemesService) {
        self.themesService = themesService
    }
    
    func makeProfileModule() -> UIViewController {
        let presenter = ProfilePresenter()
        let viewController = ProfileViewController(output: presenter, themesService: themesService)
        
        presenter.viewInput = viewController
        themesService.profileModule = viewController
        
        return viewController
    }
}
