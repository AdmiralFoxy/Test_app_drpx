//
//  MediaFilesViewModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Foundation
import Combine

final class MediaFilesViewModel {
    
    var cellTapAction: PassthroughSubject<FilePath, Never> {
        model.cellTapAction
    }
    
    var moveFileAction: PassthroughSubject<Void, Never> {
        model.cellMoveFileAction
    }
    
    var deleteFileAction: PassthroughSubject<Void, Never> {
        model.cellDeleteFileAction
    }
    
    var viewState: CurrentValueSubject<ViewState, Never> {
        model.viewState
    }
    
    var mediaFiles: CurrentValueSubject<[MediaFile], Never> {
        model.mediaFiles
    }
    
    var fetchMoreFilesAction: PassthroughSubject<Void, Never> {
        model.fetchMoreFilesAction
    }
    
    var dropboxCacheService: DropboxCacheProtocol {
        model.dropboxCacheService
    }
    
    private let model: MediaFilesModel
    
    init(model: MediaFilesModel) {
        self.model = model
    }
    
}
