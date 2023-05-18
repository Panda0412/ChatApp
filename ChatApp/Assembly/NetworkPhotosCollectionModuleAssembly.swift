//
//  NetworkPhotosCollectionModuleAssembly.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 26.04.2023.
//

import UIKit

final class NetworkPhotosCollectionModuleAssembly {
    
    func makeNetworkPhotosCollectionModule(profile: NetworkPhotosCollectionPresenterOutput) -> UIViewController {
        let presenter = NetworkPhotosCollectionPresenter()
        let viewController = NetworkPhotosCollectionViewController(output: presenter)
        
        presenter.viewInput = viewController
        presenter.profile = profile
        
        return viewController
    }
}
