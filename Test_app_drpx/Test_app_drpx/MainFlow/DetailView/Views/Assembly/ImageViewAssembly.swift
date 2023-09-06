//
//  ImageViewAssembly.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 05/09/2023.
//

import Swinject

final class ImageViewAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(ImageView_Model.self) { (r, path: FilePath, dropboxService: DropboxServiceManager) in
            let parent = r.resolve(NavigationNode.self)!
            
            return ImageView_Model(
                parent: parent,
                path: path,
                dropboxService: dropboxService
            )
        }
        
        container.register(ImageViewModel.self) { (r, model: ImageView_Model) in
            return ImageViewModel(model: model)
        }
        
        container.register(ImageView.self) { (r, filePath: FilePath, dropboxService: DropboxServiceManager) in
            let model = r.resolve(ImageView_Model.self, arguments: filePath, dropboxService)!
            let viewModel = r.resolve(ImageViewModel.self, argument: model)!
            
            return ImageView(viewModel: viewModel)
        }
    }
    
}
