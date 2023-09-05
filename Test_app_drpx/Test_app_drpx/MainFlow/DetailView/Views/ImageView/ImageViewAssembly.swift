//
//  ImageViewAssembly.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 05/09/2023.
//

import Swinject

final class ImageViewAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(ImageView_Model.self) { (
            r,
            path: String,
            dropboxService: DropboxServiceManager
        ) in
            let parent = r.resolve(NavigationNode.self)!
            
            let model = ImageView_Model(
                parent: parent,
                path: path,
                dropboxService: dropboxService
            )
        }
        
        container.register(ImageViewModel.self) { r in
            let model = r.resolve(ImageView_Model.self)!
            let viewModel = ImageViewModel(model: model)
            
            return viewModel
        }
        
        container.register(ImageView.self) { r in
            let viewModel = r.resolve(ImageViewModel.self)!
            let viewController = ImageView(viewModel: viewModel)
            
            return viewController
        }
    }
    
}
