//
//  FilePath.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Foundation

struct FilePath {
    
    let path: String
    let oldPath: String?
    
    init(path: String, oldPath: String? = nil) {
        self.path = path
        self.oldPath = oldPath
    }
    
}
