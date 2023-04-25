//
//  CombineServiceProtocol.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.04.2023.
//

import Foundation
import Combine

protocol CombineServiceProtocol {
    var getProfileDataPublisher: AnyPublisher<UserProfileViewModel, Never> { get }
    func saveProfileDataPublisher(user: UserProfileViewModel) -> AnyPublisher<Data, CombineServiceError>
    func cancel()
}
