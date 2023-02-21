//
//  ViewController.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.02.2023.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        printMethodName()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        printMethodName()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        printMethodName()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        printMethodName()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        printMethodName()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        printMethodName()
    }
    
    func printMethodName(_ method: String = #function) {
        print("Called method: \(method)")
    }
}

