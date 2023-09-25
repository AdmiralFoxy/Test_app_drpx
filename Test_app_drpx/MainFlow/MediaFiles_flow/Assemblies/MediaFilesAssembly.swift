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
        container.register(MediaFilesModel.self) { (r, parent: NavigationNode?) in
            let dropboxService = r.resolve(DropboxServiceManager.self)!
            let dropboxCache = r.resolve(DropboxCacheManager.self)!
            
            return MediaFilesModel(
                parent: parent,
                dropboxService: dropboxService,
                dropboxCacheService: dropboxCache
            )
        }
        
        container.register(MediaFilesViewModel.self) { r in
            let model = r.resolve(MediaFilesModel.self, argument: container.resolve(NavigationNode.self))
            
            return MediaFilesViewModel(model: model!)
        }
        
        container.register(MediaFilesView.self) { r in
            let viewModel = r.resolve(MediaFilesViewModel.self)!
            
            return MediaFilesView(viewModel: viewModel)
        }
    }
    
}
