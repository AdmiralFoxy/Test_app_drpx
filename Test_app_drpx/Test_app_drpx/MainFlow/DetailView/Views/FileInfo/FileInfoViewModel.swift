//
//  FileInfoViewModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Foundation
import Combine

final class FileInfoViewModel {
    
    var closeButtonAction: PassthroughSubject<Void, Never> {
        model.closeButtonAction
    }
    
    var fileDetail: MediaFile {
        return model.fileDetail
    }
    
    private let model: FileInfoModel
    
    init(model: FileInfoModel) {
        self.model = model
    }
    
}
