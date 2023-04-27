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
    private let urlString = "https://api.unsplash.com/photos?client_id=J_h0tjocreY-Yck4n_YG8ZE0LLtcIaf-JUzf1etTxNE&per_page=30&order_by=popular"
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    private func loadImageList() {
        var images = [NetworkImage]()
        
        for i in 1...5 {
            guard let url = URL(string: urlString + "&page=\(i * 2)") else { return }
            let request = URLRequest(url: url)
            
            session.dataTask(with: request) { [weak self] data, _, error in
                guard error == nil else {
                    print("error=\(String(describing: error))")
                    return
                }
                
                guard let data, let self else { return }
                
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
                }
            }.resume()
        }
    }
    
    private func loadImage(for imageItem: NetworkImage, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: imageItem.url) else { return }
        let request = URLRequest(url: url)
                
        session.dataTask(with: request) { data, _, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            
            guard let data else { return }
            
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
