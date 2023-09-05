//
//  MediaFilesViewModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Foundation
import Combine

final class MediaFilesViewModel {
    
    var viewState: CurrentValueSubject<ViewState, Never> {
        model.viewState
    }
    
    var mediaFiles: CurrentValueSubject<[MediaFile], Never> {
        model.mediaFiles
    }
    
    var fetchMoreFilesAction: PassthroughSubject<Void, Never> {
        model.fetchMoreFilesAction
    }
    
    private let model: MediaFilesModel
    
    init(model: MediaFilesModel) {
        self.model = model
    }
    
}
