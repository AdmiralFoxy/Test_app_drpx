//
//  DVViewModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 03/09/2023.
//

import Foundation
import Combine

final class DVViewModel {
    
    var isShowDetailsView: CurrentValueSubject<FileType?, Never> {
        model.isShowDetailsView
    }
    var viewState: CurrentValueSubject<ViewState, Never> {
        model.viewState
    }
    
    private let model: DVModel
    
    init(model: DVModel) {
        self.model = model
    }
    
}
