//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.02.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let appNavigation = TabBarViewController()
        window?.rootViewController = appNavigation
                
        return true
    }
}
