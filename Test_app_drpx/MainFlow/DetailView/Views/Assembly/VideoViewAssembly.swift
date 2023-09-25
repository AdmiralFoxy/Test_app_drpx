//
//  VideoViewAssembly.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Swinject

final class VideoViewAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(VideoView_Model.self) { (r, path: FilePath, dropboxService: DropboxServiceManager) in
            let parent = r.resolve(NavigationNode.self)!
            
            return VideoView_Model(
                parent: parent,
                path: path,
                dropboxService: dropboxService
            )
        }
        
        container.register(VideoView_ViewModel.self) { (r, model: VideoView_Model) in
            return VideoView_ViewModel(model: model)
        }
        
        container.register(VideoView_ViewController.self) { (r, filePath: FilePath, dropboxService: DropboxServiceManager) in
            let model = r.resolve(VideoView_Model.self, arguments: filePath, dropboxService)!
            let viewModel = r.resolve(VideoView_ViewModel.self, argument: model)!
            
            return VideoView_ViewController(viewModel: viewModel)
        }
    }
    
}
