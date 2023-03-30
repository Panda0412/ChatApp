//
//  FileService.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 27.03.2023.
//

import UIKit

public enum FileServiceError: Error {
    case writingError
    case readingError
}

class FileService {
    private let documentDirectoryPath, avatarPath, usernamePath, descriptionPath: URL
    
    init() {
        documentDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        avatarPath = documentDirectoryPath.appendingPathComponent("avatar")
        usernamePath = documentDirectoryPath.appendingPathComponent("username")
        descriptionPath = documentDirectoryPath.appendingPathComponent("bio")
    }
    
    func saveData(userData: UserProfileViewModel, completion: @escaping (Result<UserProfileViewModel, Error>) -> Void) {
        readData { [weak self] result in
            guard let self else { return }
            switch result {
                case .success(let user):
                    do {
                        if let avatar = userData.image, avatar != user.image {
                            if let data = avatar.jpegData(compressionQuality: 1) {
                                try data.write(to: self.avatarPath)
                            }
                        }
                        if let nickname = userData.nickname, nickname != user.nickname {
                            try nickname.write(to: self.usernamePath, atomically: true, encoding: .utf8)
                        }
                        if let description = userData.description, description != user.description {
                            try description.write(to: self.descriptionPath, atomically: true, encoding: .utf8)
                        }
                        
                        var savedAvatar: UIImage?
                        
                        if let savedJpeg = try? Data(contentsOf: self.avatarPath) {
                            savedAvatar = UIImage(data: savedJpeg)
                        }
                        
                        let savedUser = UserProfileViewModel(nickname: try String(contentsOf: self.usernamePath, encoding: .utf8), description: try String(contentsOf: self.descriptionPath, encoding: .utf8), image: savedAvatar)
                        
                        completion(.success(savedUser))
                    } catch {
                        completion(.failure(FileServiceError.writingError))
                    }
                case .failure:
                    completion(.failure(FileServiceError.readingError))
            }
        }
    }
    
    func readData(completion: @escaping (Result<UserProfileViewModel, Error>) -> Void) {
        do {
            var savedAvatar: UIImage?
            
            if let savedJpeg = try? Data(contentsOf: self.avatarPath) {
                savedAvatar = UIImage(data: savedJpeg)
            }
            
            let savedUser = UserProfileViewModel(nickname: try String(contentsOf: self.usernamePath, encoding: .utf8), description: try String(contentsOf: self.descriptionPath, encoding: .utf8), image: savedAvatar)
            
            completion(.success(savedUser))
        } catch {
            completion(.failure(FileServiceError.readingError))
        }
    }
}
