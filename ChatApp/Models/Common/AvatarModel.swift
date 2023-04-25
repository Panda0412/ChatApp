//
//  AvatarModel.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.04.2023.
//

import UIKit

struct AvatarModel {
    let size: Double
    let nickname: String?
    let image: UIImage?
    
    init(size: Double, nickname: String? = nil, image: UIImage? = nil) {
        self.size = size
        self.nickname = nickname
        self.image = image
    }
}
