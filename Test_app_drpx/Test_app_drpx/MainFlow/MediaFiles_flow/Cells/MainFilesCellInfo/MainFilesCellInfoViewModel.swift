//
//  MainFilesCellInfoViewModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Combine
import UIKit

final class MainFilesCellInfoViewModel {
    
    var setImgPreviewAction: PassthroughSubject<UIImage, Never> {
        model.setImgPreviewAction
    }
    
    var cancelImgLoadingAction: PassthroughSubject<Void, Never> {
        model.cancelImgLoadingAction
    }
    
    var moveFileAction: PassthroughSubject<Void, Never> {
        model.moveFileAction
    }
    
    var deleteFileAction: PassthroughSubject<Void, Never> {
        model.deleteFileAction
    }
    
    var cellTapAction: PassthroughSubject<FilePath, Never> {
        model.cellTapAction
    }
    
    var title: String {
        model.title
    }
    
    var filePath: String {
        model.filePath
    }
    
    private let model: MainFilesCellInfoModel
    
    init(model: MainFilesCellInfoModel) {
        self.model = model
    }
    
}
