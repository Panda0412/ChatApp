//
//  profileViewProtocols.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 18.04.2023.
//

import Foundation

protocol ProfileViewOutput {
    func viewIsReady()
    func saveUserData(_: UserProfileViewModel)
}

protocol ProfileViewInput: AnyObject {
    func setIsLoading()
    func showData(_: UserProfileViewModel)
    func showAlert(for type: AlertType)
}
