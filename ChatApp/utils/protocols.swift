//
//  protocols.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 06.03.2023.
//

import UIKit

protocol ConfigurableViewProtocol {
    associatedtype ConfigurationModel
    func configure(with model: ConfigurationModel)
}

protocol ThemesPickerDelegate: UIViewController {
    var currentTheme: UIUserInterfaceStyle { get set }
    func changeUserInterfaceStyle(theme: UIUserInterfaceStyle)
}

protocol MultithreadingServiceProtocol {
    var fileService: FileService { get set }
    
    func save(user: UserProfileViewModel, completion: @escaping (Result<UserProfileViewModel, Error>) -> Void)
    func fetchUser(completion: @escaping (Result<UserProfileViewModel, Error>) -> Void)
    func cancel()
}