//
//  PhotosCollectionViewCell.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 27.04.2023.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell, ConfigurableViewProtocol {
    
    // MARK: - Setup
    
    private let imageView = UIImageView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        imageView.removeFromSuperview()
        contentView.backgroundColor = .systemBackground
    }
    
    func configure(with model: NetworkImage) {
        contentView.backgroundColor = UIColor(hexString: model.color)
        
        if let image = model.image {
            imageView.image = image
            imageView.frame = contentView.frame
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
            
            contentView.addSubview(imageView)
        }
    }
}
