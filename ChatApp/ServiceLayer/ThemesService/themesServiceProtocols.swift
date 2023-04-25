//
//  themesServiceProtocols.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.04.2023.
//

import UIKit

protocol ThemesServiceOutput: AnyObject {
    func setupTheme(_: UIUserInterfaceStyle)
}

protocol ThemesServiceInput: AnyObject {
    func viewIsReady()
    func changeTheme(to: UIUserInterfaceStyle)
}
