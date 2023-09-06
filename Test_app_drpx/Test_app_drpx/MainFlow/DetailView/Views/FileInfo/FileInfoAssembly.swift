//
//  FileInfoAssembly.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Swinject

final class FileDetailAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(FileInfoModel.self) { (r, file: MediaFile, parent: NavigationNode) in
            return FileInfoModel(parent: parent, fileDetail: file)
        }
        
        container.register(FileInfoViewModel.self) { (r, model: FileInfoModel) in
            return FileInfoViewModel(model: model)
        }
        
        container.register(FileInfoViewController.self) { (r, fileDetail: MediaFile, parent: NavigationNode) in
            guard let model = r.resolve(FileInfoModel.self, arguments: fileDetail, parent) else {
                fatalError("Could not resolve FileInfoModel")
            }

            let viewModel = r.resolve(FileInfoViewModel.self, argument: model)!
            
            let viewController = FileInfoViewController()
            viewController.viewModel = viewModel
            
            return viewController
        }
    }
    
}
