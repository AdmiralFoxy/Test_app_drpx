//
//  MediaFile.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Foundation
import SwiftyDropbox

struct MediaFile: Codable {
    
    let name: String
    let path: String
    let clientModified: Date?
    let serverModified: Date?
    let contentHash: String?
    let id: String?
    let isDownloadable: Bool?
    let size: Int?
    let data: Data?
    
    init(
        name: String,
        path: String,
        clientModified: Date? = nil,
        serverModified: Date? = nil,
        contentHash: String? = nil,
        id: String? = nil,
        isDownloadable: Bool? = nil,
        size: Int? = nil,
        data: Data? = nil
    ) {
        self.name = name
        self.path = path
        self.clientModified = clientModified
        self.serverModified = serverModified
        self.contentHash = contentHash
        self.id = id
        self.isDownloadable = isDownloadable
        self.size = size
        self.data = data
    }
    
    static func setupMetadata(data: Data, metadata: Files.Metadata) -> MediaFile {
        let fileMetadata = metadata as? Files.FileMetadata
        
        return MediaFile(
            name: metadata.name,
            path: metadata.pathLower ?? "",
            clientModified: fileMetadata?.clientModified,
            serverModified: fileMetadata?.serverModified,
            contentHash: fileMetadata?.contentHash,
            id: fileMetadata?.id,
            isDownloadable: fileMetadata?.isDownloadable,
            size: Int(fileMetadata?.size ?? 0),
            data: data
        )
    }
    
}

extension MediaFile: Equatable {
    
    static func ==(lhs: MediaFile, rhs: MediaFile) -> Bool {
        return lhs.name == rhs.name && lhs.path == rhs.path
    }
    
}
