//
//  NetworkImage.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 27.04.2023.
//

import UIKit

struct NetworkImage: Decodable {
    let color: String
    let url: String
    let image: UIImage?
    
    private enum NetworkResponseKeys: CodingKey {
        case color
        case urls
    }

    private enum UrlsKeys: String, CodingKey {
        case url = "regular"
    }
    
    init(color: String, url: String, image: UIImage?) {
        self.color = color
        self.url = url
        self.image = image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NetworkResponseKeys.self)
        let urlsContainer = try container.nestedContainer(keyedBy: UrlsKeys.self, forKey: .urls)

        self.color = try container.decode(String.self, forKey: .color)
        self.url = try urlsContainer.decode(String.self, forKey: .url)
        self.image = nil
    }
}
