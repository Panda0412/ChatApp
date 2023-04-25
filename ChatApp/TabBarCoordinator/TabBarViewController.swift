//
//  TabBarViewController.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 11.04.2023.
//

import UIKit

private enum Constants {
    static let themeKey = "theme"
}

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScreens()
    }
    
    init() {
        channelsScreen = ChannelsListModuleAssembly(themesService: themesService).makeChannelsListModule()
        settingsScreen = SettingsModuleAssembly(themesService: themesService).makeSettingsModule()
        profileScreen = ProfileModuleAssembly(themesService: themesService).makeProfileModule()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private let themesService = ThemesService()
    private let channelsScreen, settingsScreen, profileScreen: UIViewController
    
    private func createNavController(
        for rootViewController: UIViewController,
        title: String,
        image: UIImage?
    ) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        
        navController.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: nil)
        navController.navigationBar.prefersLargeTitles = true
                
        rootViewController.navigationItem.title = title
        
        return navController
    }
    
    func setupScreens() {
        themesService.navigator = self
        
        viewControllers = [
            createNavController(for: channelsScreen, title: "Channels", image: UIImage(systemName: "bubble.left.and.bubble.right")),
            createNavController(for: settingsScreen, title: "Settings", image: UIImage(systemName: "gear")),
            createNavController(for: profileScreen, title: "My profile", image: UIImage(systemName: "person"))
        ]
    }
}

extension TabBarViewController: ThemesServiceOutput {
    func setupTheme(_ theme: UIUserInterfaceStyle) {
        overrideUserInterfaceStyle = theme
    }
}
