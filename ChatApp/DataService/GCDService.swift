//
//  GCDService.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 28.03.2023.
//

import Foundation

class GCDService: MultithreadingServiceProtocol {
    var fileService = FileService()
    private var queue: DispatchQueue = .init(label: "queue")
    private var workItem: DispatchWorkItem?
    
    func save(user: UserProfileViewModel, completion: @escaping (Result<UserProfileViewModel, Error>) -> Void) {
        workItem = DispatchWorkItem(qos: .userInitiated, flags: .noQoS, block: { [weak self] in
            sleep(2)
            guard let self else { return }
            guard let isCanceled = self.workItem?.isCancelled, !isCanceled else { return }
            
            self.fileService.saveData(userData: user) { result in
                DispatchQueue.main.async {
                    switch result {
                        case .success(let user):
                            completion(.success(user))
                        case .failure(let writingError):
                            completion(.failure(writingError))
                    }
                }
            }
            
            self.workItem = nil
        })
        
        guard let workItem else { return }
        queue.async(execute: workItem)
    }
    
    func fetchUser(completion: @escaping (Result<UserProfileViewModel, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self else { return }
            self.fileService.readData { result in
                DispatchQueue.main.async {
                    switch result {
                        case .success(let user):
                            completion(.success(user))
                        case .failure(let readingError):
                            completion(.failure(readingError))
                    }
                }
            }
        }
    }
    
    func cancel() {
        workItem?.cancel()
    }
}
