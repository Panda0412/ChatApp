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
        var prevData = UserProfileViewModel()
        readData { result in
            switch result {
                case .success(let user):
                    prevData = user
                case .failure: break
            }
        }
        
        do {
            if let avatar = userData.image, avatar != prevData.image {
                if let data = avatar.jpegData(compressionQuality: 1) {
                    try data.write(to: avatarPath)
                }
            }
            if let nickname = userData.nickname, nickname != prevData.nickname {
                try nickname.write(to: usernamePath, atomically: true, encoding: .utf8)
            }
            if let description = userData.description, description != prevData.description {
                try description.write(to: descriptionPath, atomically: true, encoding: .utf8)
            }
            
            var savedAvatar: UIImage?
            
            if let savedJpeg = try? Data(contentsOf: avatarPath) {
                savedAvatar = UIImage(data: savedJpeg)
            }
            
            let savedUser = UserProfileViewModel(nickname: try String(contentsOf: usernamePath, encoding: .utf8), description: try String(contentsOf: descriptionPath, encoding: .utf8), image: savedAvatar)
            
            completion(.success(savedUser))
        } catch {
            completion(.failure(FileServiceError.writingError))
        }
    }
    
    func readData(completion: @escaping (Result<UserProfileViewModel, Error>) -> Void) {
        do {
            var savedAvatar: UIImage?
            
            if let savedJpeg = try? Data(contentsOf: avatarPath) {
                savedAvatar = UIImage(data: savedJpeg)
            }
            
            let savedUser = UserProfileViewModel(nickname: try String(contentsOf: usernamePath, encoding: .utf8), description: try String(contentsOf: descriptionPath, encoding: .utf8), image: savedAvatar)
            
            completion(.success(savedUser))
        } catch {
            completion(.failure(FileServiceError.readingError))
        }
    }
}
