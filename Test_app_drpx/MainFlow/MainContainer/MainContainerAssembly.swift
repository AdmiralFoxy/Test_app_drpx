//
//  MainContainerAssembly.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 03/09/2023.
//

import Swinject

final class MainContainerAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(MainContainerView.self) { r in
            let controller = MainContainerView()
            
            return controller
        }
    }
    
}
