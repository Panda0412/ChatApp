//
//  OperationService.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 29.03.2023.
//

import Foundation

class OperationService: MultithreadingServiceProtocol {
    var fileService = FileService()
    private var queue = OperationQueue()
    
    private var saveOperation: SaveOperation?
    
    func save(user: UserProfileViewModel, completion: @escaping (Result<UserProfileViewModel, Error>) -> Void) {
        saveOperation = SaveOperation(user: user, fileService: fileService)
        guard let saveOperation else { return }
        
        saveOperation.completionBlock = {
            OperationQueue.main.addOperation {
                switch saveOperation.result {
                    case .success(let user):
                        completion(.success(user))
                    case .failure(let writingError):
                        completion(.failure(writingError))
                    default: break
                }
            }
        }
        
        queue.addOperation(saveOperation)
    }
    
    func fetchUser(completion: @escaping (Result<UserProfileViewModel, Error>) -> Void) {
        let fetchOperation = FetchOperation(fileService: fileService)
        
        fetchOperation.completionBlock = {
            OperationQueue.main.addOperation {
                switch fetchOperation.result {
                    case .success(let user):
                        completion(.success(user))
                    case .failure(let readingError):
                        completion(.failure(readingError))
                    default: break
                }
            }
        }
        
        queue.addOperation(fetchOperation)
    }
    
    func cancel() {
        saveOperation?.cancel()
    }
    

}

class SaveOperation: AsyncOperation {
    private let user: UserProfileViewModel
    private var fileService: FileService
    var result: Result<UserProfileViewModel, Error>?
        
    init(user: UserProfileViewModel, fileService: FileService) {
        self.user = user
        self.fileService = fileService
        super.init()
    }
    
    override func main() {
        sleep(2)
        
        if isCancelled {
            finish()
            return
        }
        
        self.fileService.saveData(userData: user) { [weak self] result in
            self?.result = result
            self?.finish()
        }
    }
}

class FetchOperation: AsyncOperation {
    private var fileService: FileService
    var result: Result<UserProfileViewModel, Error>?
        
    init(fileService: FileService) {
        self.fileService = fileService
        super.init()
    }
    
    override func main() {
        if isCancelled {
            finish()
            return
        }
        
        self.fileService.readData { [weak self] result in
            self?.result = result
            self?.finish()
        }
    }
}
