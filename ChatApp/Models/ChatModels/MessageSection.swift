//
//  MessageSection.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.04.2023.
//

import Foundation

struct MessageSection: Hashable {
    let date: Date
    var messages: [MessageItem]
}
