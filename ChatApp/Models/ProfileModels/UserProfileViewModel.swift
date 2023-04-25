//
//  UserProfileViewModel.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.04.2023.
//

import UIKit

struct UserProfileViewModel: Codable {
    let nickname: String?
    let description: String?
    let image: AvatarImage?
    
    init(nickname: String? = nil, description: String? = nil, image: UIImage? = nil) {
        self.nickname = nickname
        self.description = description
        self.image = AvatarImage(image: image)
    }
}
