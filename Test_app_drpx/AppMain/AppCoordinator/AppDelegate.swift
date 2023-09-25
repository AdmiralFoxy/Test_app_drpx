//
//  AppDelegate.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 30/08/2023.
//

import UIKit
import SwiftyDropbox
import AppTrackingTransparency
import AdSupport

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
            // Setup Dropbox with API key
            DropboxClientsManager.setupWithAppKey(appConstants.apiKey)
            
            // Setup main window
            window = UIWindow(frame: UIScreen.main.bounds)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Request App Tracking Transparency permission
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    switch status {
                    case .authorized:
                        // Code to handle authorized status, possibly retrieve IDFA value
                        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        print("IDFA: \(idfa)")
                    case .denied:
                        // Code to handle denied status
                        print("Tracking authorization denied")
                    case .restricted:
                        // Code to handle restricted status
                        print("Tracking authorization restricted")
                    case .notDetermined:
                        // Code to handle not determined status
                        print("Tracking authorization not determined")
                    @unknown default:
                        // Code to handle unknown status (for future iOS versions)
                        print("Tracking authorization unknown status")
                    }
                })
            }
            
            return true
        }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
    
}
