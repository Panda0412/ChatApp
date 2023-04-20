//
//  MessageCellModel.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.04.2023.
//

import Foundation

struct MessageCellModel {
    let userName: String
    let message: String
    let date: Date
    let isIncoming: Bool
    var isBubbleTailNeeded: Bool
    var isNicknameNeeded: Bool
}
