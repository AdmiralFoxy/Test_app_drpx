//
//  MediaFilesAssembly.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Swinject
import SwiftyDropbox

final class MediaFilesAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(DropboxClient.self) { _ in
            let client = DropboxClient(accessToken: AppConstants.shared.apiKey)
            
            return client
        }
        
        container.register(DropboxServiceManager.self) { r in
            let client = r.resolve(DropboxClient.self)!
            
            return DropboxServiceManager(client: client)
        }.inObjectScope(.container)
        
        container.register(MediaFilesModel.self) { r in
            let dropboxService = r.resolve(DropboxServiceManager.self)!
            
            return MediaFilesModel(dropboxService: dropboxService)
        }
        
        container.register(MediaFilesViewModel.self) { r in
            let model = r.resolve(MediaFilesModel.self)!
            
            return MediaFilesViewModel(model: model)
        }
        
        container.register(MediaFilesView.self) { r in
            let viewModel = r.resolve(MediaFilesViewModel.self)!
            
            return MediaFilesView(viewModel: viewModel)
        }
    }
    
}
