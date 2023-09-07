//
//  DetailViewEvents.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 07/09/2023.
//

import Foundation

enum DetailViewEvents: NavigationEvent {
    
    case showImage(filePath: FilePath)
    case showPDF(filePath: FilePath)
    case showVideo(filePath: FilePath)
    
    static func getDetailViewEvent(for path: FilePath) -> DetailViewEvents? {
        let formattedPath = path.path.replacingOccurrences(of: " ", with: "%20")
        guard let fileExtension = URL(string: formattedPath)?.pathExtension.lowercased() else {
            return nil
        }
        
        switch fileExtension {
        case "jpg", "jpeg", "png":
            return .showImage(filePath: path)
        case "pdf":
            return .showPDF(filePath: path)
        case "mp4", "mov", "avi":
            return .showVideo(filePath: path)
        default:
            return nil
        }
    }
    
}
