//
//  chatViewProtocols.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 18.04.2023.
//

import Foundation

protocol ChatViewOutput {
    func viewIsReady()
    func sendMessage(_: String)
}

protocol ChatViewInput: AnyObject {
    func showData(_: [MessageSection], animated: Bool)
    func showAlert()
    func clearTextField()
}
