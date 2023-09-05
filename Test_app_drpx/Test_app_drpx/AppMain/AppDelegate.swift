//
//  AppDelegate.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 30/08/2023.
//

import UIKit
import SwiftyDropbox

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    private let appConstants = AppConstants.shared
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [
            UIApplication.LaunchOptionsKey: Any
        ]?) -> Bool {
            DropboxClientsManager.setupWithAppKey(appConstants.apiKey)
            window = UIWindow(frame: UIScreen.main.bounds)
            
            return true
        }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
    
}
