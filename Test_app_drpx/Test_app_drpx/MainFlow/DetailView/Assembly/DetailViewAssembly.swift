//
//  DetailViewAssembly.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 03/09/2023.
//

import Swinject
import SwiftyDropbox

final class DetailViewAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(DropboxClient.self) { _ in
            let client = DropboxClient(accessToken: AppConstants.shared.apiKey)
            
            return client
        }
        
        container.register(DropboxServiceManager.self) { r in
            let client = r.resolve(DropboxClient.self)!
            
            return DropboxServiceManager(client: client)
        }.inObjectScope(.container)
        
        container.register(DVModel.self) { (resolver, mediaFile: MediaFile) in
            let dropbox = resolver.resolve(DropboxServiceManager.self)!
            let model = DVModel(mediaFiles: mediaFile, dropboxService: dropbox)
            
            return model
        }
        
        container.register(DVViewModel.self) { r in
            let model = r.resolve(DVModel.self)!
            let viewModel = DVViewModel(model: model)
            
            return viewModel
        }
        
        container.register(DVViewController.self) { r in
            let viewModel = r.resolve(DVViewModel.self)!
            let vc = DVViewController(viewModel: viewModel)
            
            return vc
        }
    }
    
}
