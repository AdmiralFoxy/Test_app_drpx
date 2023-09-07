//
//  AppMainEvents.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 07/09/2023.
//

import Foundation

enum AppMainEvents: NavigationEvent {
    
    case auth
    case mainFiles
    case infoView(file: MediaFile)
    
}
