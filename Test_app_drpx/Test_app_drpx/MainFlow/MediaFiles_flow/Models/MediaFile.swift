//
//  MediaFile.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Foundation

struct MediaFile {
    
    let name: String
    let path: String
    
}

extension MediaFile: Equatable {
    
    static func ==(lhs: MediaFile, rhs: MediaFile) -> Bool {
        return lhs.name == rhs.name && lhs.path == rhs.path
    }
    
}
