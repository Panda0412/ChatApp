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
    func isNotMyId(_: String) -> Bool
}

protocol ChatViewInput: AnyObject {
    func showData(_: [MessageSection], animated: Bool)
    func showAlert()
    func clearTextField()
}
