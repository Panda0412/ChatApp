//
//  networkPhotosCollectionViewProtocols.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 26.04.2023.
//

import Foundation

protocol NetworkPhotosCollectionViewOutput {
    func viewIsReady()
    func loadImageData(for imageItem: NetworkImage, completion: @escaping (Result<Data, Error>) -> Void)
    func didSelectItem(_ item: NetworkImage)
}

protocol NetworkPhotosCollectionViewInput: AnyObject {
    func showData(_: [NetworkImage])
    func showAlert()
}
