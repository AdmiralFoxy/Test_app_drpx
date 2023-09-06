//
//  AuthAssembly.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 01/09/2023.
//

import Swinject
import SwiftyDropbox

final class AuthAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(DropboxClient.self) { _ in
            let client = DropboxClient(accessToken: AppConstants.shared.apiKey)
            
            return client
        }
        
        container.register(DropboxServiceManager.self) { r in
            return DropboxServiceManager()
        }.inObjectScope(.container)
        
        container.register(AuthModel.self) { r in
            let dropboxService = r.resolve(DropboxServiceManager.self)!
            
            return AuthModel(dropboxService: dropboxService)
        }
        
        container.register(AuthViewModel.self) { r in
            let model = r.resolve(AuthModel.self)!
            
            return AuthViewModel(model: model)
        }
        
        container.register(AuthViewController.self) { r in
            let viewModel = r.resolve(AuthViewModel.self)!
            let navigationNode = r.resolve(NavigationNode.self)!
            
            return AuthViewController(
                viewModel: viewModel,
                navigationNode: navigationNode
            )
        }
    }
    
}
