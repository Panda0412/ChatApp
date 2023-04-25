//
//  AvatarImage.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.04.2023.
//

import UIKit

struct AvatarImage: Codable {
    let image: UIImage?
    
    init(image: UIImage?) {
        self.image = image
    }
    
    enum CodingKeys: CodingKey { case data }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let data = try? container.decode(Data.self, forKey: .data) {
            self.image = UIImage(data: data)
        } else {
            self.image = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let image = self.image {
            try container.encode(image.pngData(), forKey: .data)
        }
    }
}
