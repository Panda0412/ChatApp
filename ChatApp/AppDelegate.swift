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
    var stateLabel = UILabel()
    var isLoggingNeeded = CommandLine.arguments.contains { $0 == "isLoggingNeeded" }
    
    let green = UIColor(red: 0.49, green: 0.74, blue: 0.47, alpha: 1.00)
    let yellow = UIColor(red: 0.97, green: 0.85, blue: 0.44, alpha: 1.00)
    let blue = UIColor(red: 0.45, green: 0.73, blue: 0.93, alpha: 1.00)
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        printAppState(from: "Not-running", to: "Inavtive")

        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        stateLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        stateLabel.center = CGPoint(
            x: (window?.rootViewController?.view.frame.size.width ?? 0) / 2,
            y: (window?.rootViewController?.view.frame.size.height ?? 0) / 2
        )
        stateLabel.textAlignment = .center
        stateLabel.font = UIFont.systemFont(ofSize: 45)
        window?.rootViewController?.view.addSubview(stateLabel)
        
        window?.rootViewController?.view.backgroundColor = yellow
        stateLabel.text = "Inactive"
                
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        printAppState(from: "Inavtive", to: "Active")

        window?.rootViewController?.view.backgroundColor = green
        stateLabel.text = "Active"
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        printAppState(from: "Active", to: "Inavtive")

        window?.rootViewController?.view.backgroundColor = yellow
        stateLabel.text = "Inactive"
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        printAppState(from: "Inavtive", to: "Background")

        window?.rootViewController?.view.backgroundColor = blue
        stateLabel.text = "Background"
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        printAppState(from: "Background", to: "Inavtive")

        window?.rootViewController?.view.backgroundColor = yellow
        stateLabel.text = "Inactive"
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        printAppState(from: "Background", to: "Not-running")
    }
    
    func printAppState(_ method: String = #function, from: String, to: String) {
        if isLoggingNeeded {
            print("\(method): \(from) → \(to)")
        }
    }
}
