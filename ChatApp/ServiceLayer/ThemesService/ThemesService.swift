//
//  ThemesService.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.04.2023.
//

import Foundation
import UIKit

private enum Constants {
    static let themeKey = "theme"
}

final class ThemesService {
    
    weak var channelsListModule, settingsModule, profileModule, navigator: ThemesServiceOutput?

    private let defaults = UserDefaults.standard
    private var currentTheme: UIUserInterfaceStyle = .light
    
    init() {
        let storedTheme = UIUserInterfaceStyle(rawValue: defaults.integer(forKey: Constants.themeKey))
        guard let theme = storedTheme, theme == .light || theme == .dark else {
            return
        }
        
        currentTheme = theme
    }
    
    private func updateAllScreens() {
        channelsListModule?.setupTheme(currentTheme)
        settingsModule?.setupTheme(currentTheme)
        profileModule?.setupTheme(currentTheme)
        navigator?.setupTheme(currentTheme)
    }
}

extension ThemesService: ThemesServiceInput {
    func viewIsReady() {
        updateAllScreens()
    }
    
    func changeTheme(to theme: UIUserInterfaceStyle) {
        currentTheme = theme
        updateAllScreens()
        defaults.set(theme.rawValue, forKey: Constants.themeKey)
    }
}
