//
//  AppSingletoneAssembly.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 07/09/2023.
//

import Swinject

final class AppSingletoneAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(DropboxServiceManager.self) { _ in
            return DropboxServiceManager()
        }.inObjectScope(.container)
        
        container.register(DropboxCacheManager.self) { r in
            let service = r.resolve(DropboxServiceManager.self)!
            
            return DropboxCacheManager(dropboxServiceManager: service)
        }.inObjectScope(.container)
    }
    
}
