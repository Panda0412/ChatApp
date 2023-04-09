//
//  CombineService.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 31.03.2023.
//

import Combine
import UIKit
import Foundation

public enum CombineServiceError: Error {
    case writingError
    case readingError
    case cancel
}

class CombineService {
    private let filePath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("profileData")
    private let backgroundQueue = DispatchQueue.global(qos: .userInitiated)
    private var isSavingCancelled = false
    
    private let currentProfileDataSubject: CurrentValueSubject<Data?, Error> = CurrentValueSubject(nil)
    
    var getProfileDataPublisher: AnyPublisher<UserProfileViewModel, Never> {
        currentProfileDataSubject
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .decode(type: UserProfileViewModel.self, decoder: JSONDecoder())
            .catch { _ in Just(UserProfileViewModel()) }
            .eraseToAnyPublisher()
    }
    
    init() {
        backgroundQueue.async {
            self.getProfileData() { [weak self] result in
                guard let self else { return }
                switch result {
                    case .success(let user):
                        self.currentProfileDataSubject.send(user)
                    case .failure(let error):
                        self.currentProfileDataSubject.send(completion: .failure(error))
                }
            }
        }
    }
    
    private func getProfileData(completion: @escaping (Result<Data, Error>) -> Void) {
        backgroundQueue.sync { [weak self] in
            guard let self else { return }
            do {
                let savedUser = try Data(contentsOf: self.filePath)
                                
                completion(.success(savedUser))
            } catch {
                completion(.failure(CombineServiceError.readingError))
            }
        }
    }
        
    func saveProfileDataPublisher(user: UserProfileViewModel) -> AnyPublisher<Data, CombineServiceError> {
        Deferred {
            Future<UserProfileViewModel, Never> { promise in
                self.isSavingCancelled = false
                promise(.success(user))
            }
            .subscribe(on: self.backgroundQueue)
            .receive(on: DispatchQueue.main)
            .encode(encoder: JSONEncoder())
            .tryMap { [weak self] userData in
                guard let self else { throw CombineServiceError.writingError }
                
                guard self.isSavingCancelled == false else {
                    throw CombineServiceError.cancel
                }
                
                try userData.write(to: self.filePath)
                self.currentProfileDataSubject.send(userData)
                
                return userData
            }
            .mapError { error in
                if let combineServiceError = error as? CombineServiceError, combineServiceError == CombineServiceError.cancel {
                    return combineServiceError
                } else {
                    return CombineServiceError.writingError
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func cancel() {
        isSavingCancelled = true
    }
}

let sharedCombineService = CombineService()
