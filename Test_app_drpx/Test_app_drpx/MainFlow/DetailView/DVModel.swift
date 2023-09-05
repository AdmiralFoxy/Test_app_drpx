//
//  DVModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 03/09/2023.
//

import Foundation
import Combine

final class DVModel {
    
    let mediaFiles: MediaFile
    let isShowDetailsView = CurrentValueSubject<FileType?, Never>(nil)
    let viewState = CurrentValueSubject<ViewState, Never>(.idle)
    
    private let dropboxService: DropboxServiceManager
    
    init(mediaFiles: MediaFile, dropboxService: DropboxServiceManager) {
        self.mediaFiles = mediaFiles
        self.dropboxService = dropboxService
        
        loadFileData(path: mediaFiles.path)
    }
    
}

private extension DVModel {
    
    func loadFileData(path pathName: String) {
        viewState.send(.loading)
        
        let fileExtension = (pathName as NSString).pathExtension.lowercased()
        
        dropboxService.downloadFile(path: pathName) { [weak self] data, error in
            guard let self = self else { return }

            if let data = data {
                DispatchQueue.main.async {
                    if let matchedType = FileExtension.match(fileExtension) {
                        switch matchedType {
                        case .image:
                            self.isShowDetailsView.send(.image(data: data))
                        case .pdf:
                            self.isShowDetailsView.send(.pdf(data: data))
                        case .video:
                            self.isShowDetailsView.send(.video(data: data))
                        }
                        
                        self.viewState.send(.onSuccess)
                    } else {
                        print("Unsupported file type")
                        self.viewState.send(.onFailure("Unsupported file type"))
                    }
                }
            } else {
                let errorMessage = error?.localizedDescription ?? "DVModel: loading error"
                self.viewState.send(.onFailure(errorMessage))
            }
        }
    }
    
}
