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
        
        setupTheme()
        setupScreens()
    }
    
    private let defaults = UserDefaults.standard
    var currentTheme: UIUserInterfaceStyle = .light
    
    private let settingsScreen = ThemesViewController()
    private let profile = ProfileViewController()
    
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
        settingsScreen.delegate = self
        profile.currentTheme = currentTheme
        
        viewControllers = [
            createNavController(for: ConversationsListViewController(), title: "Channels", image: UIImage(systemName: "bubble.left.and.bubble.right")),
            createNavController(for: settingsScreen, title: "Settings", image: UIImage(systemName: "gear")),
            createNavController(for: profile, title: "My profile", image: UIImage(systemName: "person"))
        ]
    }
    
    private func setupTheme() {
        let storedTheme = UIUserInterfaceStyle(rawValue: defaults.integer(forKey: Constants.themeKey))
        guard let theme = storedTheme, theme == .light || theme == .dark else {
            overrideUserInterfaceStyle = .light
            return
        }
        
        overrideUserInterfaceStyle = theme
        currentTheme = theme
    }
}

extension TabBarViewController: ThemesPickerDelegate {
    func changeUserInterfaceStyle(theme: UIUserInterfaceStyle) {
        overrideUserInterfaceStyle = theme
        currentTheme = theme
        profile.currentTheme = theme
        defaults.set(theme.rawValue, forKey: Constants.themeKey)
    }
}
