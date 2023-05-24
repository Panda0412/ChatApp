//
//  NetworkPhotosCollectionPresenter.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 26.04.2023.
//

import Foundation

final class NetworkPhotosCollectionPresenter {
    
    weak var viewInput: NetworkPhotosCollectionViewInput?
    weak var profile: NetworkPhotosCollectionPresenterOutput?
    private let session: URLSession
    private let clientId = Bundle.main.object(forInfoDictionaryKey: "ClientId") as? String
    private let baseUrl = Bundle.main.object(forInfoDictionaryKey: "BaseUrl") as? String
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    private func loadImageList() {
        var images = [NetworkImage]()
        
        guard let clientId, let baseUrl else {
            viewInput?.showAlert()
            return
        }
        
        for i in 1...5 {
            guard let url = URL(string: "\(baseUrl)&client_id=\(clientId)&page=\(i * 2)") else {
                viewInput?.showAlert()
                return
            }
            let request = URLRequest(url: url)
            
            session.dataTask(with: request) { [weak self] data, _, error in
                guard let self else { return }
                
                guard error == nil, let data else {
                    self.viewInput?.showAlert()
                    return
                }
                
                do {
                    let networkImages = try JSONDecoder().decode([NetworkImage].self, from: data)
                    
                    images.append(contentsOf: networkImages)
                                        
                    if images.count == 150 {
                        DispatchQueue.main.async {
                            self.viewInput?.showData(images)
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                    self.viewInput?.showAlert()
                }
            }.resume()
        }
    }
    
    private func loadImage(for imageItem: NetworkImage, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: imageItem.url) else {
            viewInput?.showAlert()
            return
        }
        let request = URLRequest(url: url)
                
        session.dataTask(with: request) { [weak self] data, _, error in
            guard error == nil, let data else {
                self?.viewInput?.showAlert()
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }.resume()
    }
}

extension NetworkPhotosCollectionPresenter: NetworkPhotosCollectionViewOutput {
    func viewIsReady() {
        loadImageList()
    }
    
    func loadImageData(for imageItem: NetworkImage, completion: @escaping (Result<Data, Error>) -> Void) {
        loadImage(for: imageItem, completion: completion)
    }
    
    func didSelectItem(_ item: NetworkImage) {
        profile?.setupAvatar(item.image)
    }
}
