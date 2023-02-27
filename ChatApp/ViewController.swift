//
//  ViewController.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.02.2023.
//

import UIKit

class ViewController: UIViewController {
    
    var isLoggingNeeded = CommandLine.arguments.contains { $0 == "isLoggingNeeded" }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

