//
//  protocols.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 06.03.2023.
//

protocol ConfigurableViewProtocol {
    associatedtype ConfigurationModel
    func configure(with model: ConfigurationModel)
}
