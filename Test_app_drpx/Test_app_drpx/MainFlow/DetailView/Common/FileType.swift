//
//  FileType.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 04/09/2023.
//

import Foundation

enum FileExtension: String {
    
    case image = "jpg,jpeg,png"
    case pdf = "pdf"
    case video = "mp4,mov"

    static func match(_ valueType: String) -> FileExtension? {
        for fileType in [FileExtension.image, FileExtension.pdf, FileExtension.video] {
            if fileType.rawValue.contains(valueType) {
                return fileType
            }
        }
        return nil
    }
    
}

enum FileType {
    
    case image(data: Data)
    case pdf(data: Data)
    case video(data: Data)
    
}
