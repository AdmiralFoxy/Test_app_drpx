//
//  ImageViewModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 04/09/2023.
//

import Foundation
import Combine
import UIKit

final class ImageViewModel {
    
    var setImageAction: PassthroughSubject<UIImage, Never> {
        model.setImageAction
    }
    
    var viewState: CurrentValueSubject<ViewState, Never> {
        model.viewState
    }
    
    var viewButtonAction: PassthroughSubject<DVButtonType, Never> {
        model.viewButtonAction
    }
    
    var filePath: String {
        model.filePath
    }
    
    private let model: ImageView_Model
    
    init(model: ImageView_Model) {
        self.model = model
    }
    
}
