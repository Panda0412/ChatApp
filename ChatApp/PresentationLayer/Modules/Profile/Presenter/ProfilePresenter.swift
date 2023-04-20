//
//  ProfilePresenter.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 18.04.2023.
//

import Foundation
import Combine

final class ProfilePresenter {
    
    weak var viewInput: ProfileViewInput?
    private var userDataRequest: Cancellable?
    private var saveDataRequest: Cancellable?
    private var currentUserData = UserProfileViewModel()
    
    private func fetchUserData() {
        userDataRequest = CombineService.shared.getProfileDataPublisher
            .sink { [weak self] user in
                guard let self else { return }
                self.currentUserData = user
                self.viewInput?.showData(user)
            }
    }
    
    internal func saveData(_ user: UserProfileViewModel) {
        viewInput?.setIsLoading()

        saveDataRequest = CombineService.shared.saveProfileDataPublisher(user: user)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .decode(type: UserProfileViewModel.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: { [weak self] result in
                    guard let self else { return }

                    switch result {
                    case .finished: break
                    case .failure(let error):
                        self.viewInput?.showData(self.currentUserData)
                        
                        guard let combineServiceError = error as? CombineServiceError, combineServiceError == CombineServiceError.cancel else {
                            self.viewInput?.showAlert(for: .error)
                            break
                        }
                    }
                },
                receiveValue: { [weak self] user in
                    guard let self else { return }
                    
                    self.viewInput?.showData(user)
                    self.viewInput?.showAlert(for: .success)
                })
    }
}

extension ProfilePresenter: ProfileViewOutput {
    func viewIsReady() {
        fetchUserData()
    }
    
    func saveUserData(_ user: UserProfileViewModel) {
        saveData(user)
    }
}
