//
//  PDFAssembly.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Swinject

final class PDFAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(PDFModel.self) { (r, path: FilePath, dropboxService: DropboxServiceManager) in
            let parent = r.resolve(NavigationNode.self)!
            
            return PDFModel(
                parent: parent,
                path: path,
                dropboxService: dropboxService
            )
        }
        
        container.register(PDFViewModel.self) { (r, model: PDFModel) in
            return PDFViewModel(model: model)
        }
        
        container.register(PDFViewController.self) { (r, filePath: FilePath, dropboxService: DropboxServiceManager) in
            let model = r.resolve(PDFModel.self, arguments: filePath, dropboxService)!
            let viewModel = r.resolve(PDFViewModel.self, argument: model)!
            
            return PDFViewController(viewModel: viewModel)
        }
    }
    
}
