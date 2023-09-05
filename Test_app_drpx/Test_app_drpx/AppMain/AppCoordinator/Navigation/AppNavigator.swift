//
//  AppNavigator.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Foundation
import UIKit
import Swinject

enum DetailViewEvents: NavigationEvent {
    
    case showImage(filePath: String)
    case showPDF(filePath: String)
    case showVideo(filePath: String)
    
}


enum AppMainEvents: NavigationEvent {
    
    case auth
    case mainFiles
    case detailView(MediaFile)
    case infoView(path: String)
    
}

final class AppCoordinator: NavigationNode {
    
    let window: UIWindow
    let container: Container
    
    var containerViewController: MainContainerView?
    
    init(window: UIWindow) {
        self.window = window
        self.container = Container()
        
        super.init(parent: nil)
        
        container.register(NavigationNode.self) { _ in return self}
        
        assemblyRegistr()
        setupHandler()
    }
    
    func postInit() {
        container.register(AppCoordinator.self) { _ in return self }
        containerViewController = container.resolve(MainContainerView.self)
        
        window.rootViewController = containerViewController
        window.makeKeyAndVisible()
        
        raise(event: AppMainEvents.auth)
    }
}

// MARK: - event methods

extension AppCoordinator {
    
    private func assemblyRegistr() {
        MainContainerAssembly().assemble(container: container)
        AuthAssembly().assemble(container: container)
        MediaFilesAssembly().assemble(container: container)
        DetailViewAssembly().assemble(container: container)
        ImageViewAssembly().assemble(container: container)
    }
    
    private func setupHandler() {
        addHandler { [weak self] (event: DetailViewEvents) in
                guard let self = self else { return }
                
                switch event {
                case .showImage(let filePath):
                    self.navigateToImageView(filePath: filePath)
                    
                case .showPDF(let data):
                    self.navigateToPDFView(data: data)
                    
                case .showVideo(let data):
                    self.navigateToVideoView(data: data)
                }
            }
        
        addHandler { [weak self] (event: AppMainEvents) in
            guard let self = self else { return }
            
            switch event {
            case .auth:
                self.navigateToAuth()
                
            case .mainFiles:
                self.navigateToMain()
                
            case .detailView(let mediaFile):
                self.navigateToDetailView(mediaFile: mediaFile)
                
            case .infoView(let path): break
                //                self.
            }
        }
    }
    
    private func navigateToImageView(filePath: String) {
        if let vc: ImageView = container.resolve(
            ImageView.self,
            arguments: filePath,
            container.resolve(
                DropboxServiceManager.self
            )) {
            switchTo(vc)
        }
    }

    private func navigateToPDFView(data: Data) {
        if let vc: PDFView = container.resolve(PDFView.self, argument: data) {
            switchTo(vc)
        }
    }

    private func navigateToVideoView(data: Data) {
        if let vc: VideoView = container.resolve(VideoView.self, argument: data) {
            switchTo(vc)
        }
    }
    
    private func navigateToAuth() {
        if let vc: AuthViewController = container.resolve(AuthViewController.self) {
            switchTo(UINavigationController(rootViewController: vc))
        }
    }
    
    private func navigateToMain() {
        if let vc: MediaFilesView = container.resolve(MediaFilesView.self) {
            switchTo(UINavigationController(rootViewController: vc))
        }
    }
    
    private func navigateToDetailView(mediaFile: MediaFile) {
        if let vc: DVViewController = container.resolve(
            DVViewController.self,
            argument: mediaFile
        ) {
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            containerViewController?.present(navController, animated: true, completion: nil)
        }
    }
    
    private func switchTo(_ viewController: UIViewController) {
        guard let containerViewController = containerViewController else { return }
        
        let oldVC = containerViewController.children.first
        let newVC = viewController
        
        // Если oldVC существует, удаляем его
        oldVC?.willMove(toParent: nil)
        
        // Добавляем новый VC как дочерний элемент
        containerViewController.addChild(newVC)
        
        // Устанавливаем размер и положение нового VC
        newVC.view.frame = containerViewController.view.bounds
        
        if let oldVC = oldVC {
            // Если oldVC существует, используем анимацию для перехода
            containerViewController.transition(
                from: oldVC,
                to: newVC,
                duration: 0.3,
                options: [],
                animations: {
                    // ваш код для анимации
                },
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
