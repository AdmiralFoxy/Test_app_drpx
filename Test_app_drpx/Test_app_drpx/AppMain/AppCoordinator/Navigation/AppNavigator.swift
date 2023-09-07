//
//  AppNavigator.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Foundation
import UIKit
import Swinject

final class AppCoordinator: NavigationNode {
    
    // MARK: - properties
    
    let window: UIWindow
    let container: Container
    
    var containerViewController: MainContainerView?
    
    // MARK: - initialize
    
    init(window: UIWindow) {
        self.window = window
        self.container = Container()
        
        super.init(parent: nil)
        
        setupCoordinator()
    }
    
    func postInit() {
        container.register(AppCoordinator.self) { _ in return self }
        containerViewController = container.resolve(MainContainerView.self)
        
        window.rootViewController = containerViewController
        window.makeKeyAndVisible()
        
        raise(event: AppMainEvents.auth)
    }
    
}

// MARK: - setup coordinator

private extension AppCoordinator {
    
    func setupCoordinator() {
        container.register(NavigationNode.self) { _ in return self}
        
        assemblyRegistr()
        setupHandler()
    }
    
    func assemblyRegistr() {
        AppSingletoneAssembly().assemble(container: container)
        MainContainerAssembly().assemble(container: container)
        AuthAssembly().assemble(container: container)
        MediaFilesAssembly().assemble(container: container)
        VideoViewAssembly().assemble(container: container)
        ImageViewAssembly().assemble(container: container)
        FileDetailAssembly().assemble(container: container)
        PDFAssembly().assemble(container: container)
        VideoViewAssembly().assemble(container: container)
    }
    
    private func setupHandler() {
        addHandler { [weak self] (event: DetailViewEvents) in
            guard let self = self else { return }
            
            switch event {
            case .showImage(let filePath):
                self.navigateToImageView(filePath: filePath)
                
            case .showPDF(let filePath):
                self.navigateToPDFView(filePath: filePath)
                
            case .showVideo(let filePath):
                self.navigateToVideoView(filePath: filePath)
            }
        }
        
        addHandler { [weak self] (event: AppMainEvents) in
            guard let self = self else { return }
            
            switch event {
            case .auth:
                self.navigateToAuth()
                
            case .mainFiles:
                self.navigateToMain()
                
            case .infoView(let file):
                self.navigateToInfoView(for: file)
            }
        }
    }
    
}

// MARK: - navigate methods

private extension AppCoordinator {
    
    func navigateToInfoView(for fileDetail: MediaFile) {
        let parent = container.resolve(NavigationNode.self)!
        
        if let vc: FileInfoViewController = container.resolve(
            FileInfoViewController.self,
            arguments: fileDetail,
            parent
        ) {
            switchTo(vc)
        }
    }
    
    func navigateToImageView(filePath: FilePath) {
        let dropboxService = container.resolve(DropboxServiceManager.self)!
        
        if let vc: ImageView = container.resolve(
            ImageView.self,
            arguments: filePath,
            dropboxService
        ) {
            switchTo(vc)
        }
    }
    
    func navigateToPDFView(filePath: FilePath) {
        let service = container.resolve(DropboxServiceManager.self)!
        
        if let vc: PDFViewController = container.resolve(
            PDFViewController.self,
            arguments: filePath,
            service
        ) {
            switchTo(vc)
        }
    }
    
    func navigateToVideoView(filePath: FilePath) {
        let service = container.resolve(DropboxServiceManager.self)!
        
        if let vc: VideoView_ViewController = container.resolve(
            VideoView_ViewController.self,
            arguments: filePath,
            service
        ) {
            switchTo(vc)
        }
    }
    
    func navigateToAuth() {
        if let vc: AuthViewController = container.resolve(AuthViewController.self) {
            switchTo(UINavigationController(rootViewController: vc))
        }
    }
    
    func navigateToMain() {
        if let vc: MediaFilesView = container.resolve(MediaFilesView.self) {
            switchTo(UINavigationController(rootViewController: vc))
        }
    }
    
}

// MARK: - helper methods

private extension AppCoordinator {
    
    func switchTo(_ viewController: UIViewController) {
        guard let containerViewController = containerViewController else { return }
        
        let oldVC = containerViewController.children.first
        let newVC = viewController
        
        oldVC?.willMove(toParent: nil)
        containerViewController.addChild(newVC)
        newVC.view.frame = containerViewController.view.bounds
        
        if let oldVC = oldVC {
            containerViewController.transition(
                from: oldVC,
                to: newVC,
                duration: 0.3,
                options: [],
                animations: { },
                completion: { _ in
                    oldVC.removeFromParent()
                    newVC.didMove(toParent: containerViewController)
                }
            )
        } else {
            containerViewController.view.addSubview(newVC.view)
            newVC.didMove(toParent: containerViewController)
        }
    }
    
}
