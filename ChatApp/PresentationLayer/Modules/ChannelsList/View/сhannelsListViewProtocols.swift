//
//  channelsListViewProtocols.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 18.04.2023.
//

import Foundation
import UIKit

protocol ChannelsListViewOutput {
    func viewIsReady()
    func reloadData()
    func didSelectItem(at index: Int)
    func createChannel(_ channelName: String?)
}

protocol ChannelsListViewInput: UIViewController {
    func showData(_: [ChannelItem])
    func showAlert()
    func setPrompt(_: String?)
    func endRefresh()
}
