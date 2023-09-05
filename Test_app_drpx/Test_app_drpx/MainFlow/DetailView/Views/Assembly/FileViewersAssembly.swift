//
//  FileViewersAssembly.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 04/09/2023.
//

import Swinject

final class FileViewersAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(NavigationNode.self) { (r, parent: NavigationNode?) in
            return NavigationNode(parent: parent)
        }.inObjectScope(.container)
        
        container.register(PDFView.self) { _ in
            let viewController = PDFView()
            
            return viewController
        }
        
        container.register(VideoView.self) { _ in
            let viewController = VideoView()
            
            return viewController
        }
    }
    
}
