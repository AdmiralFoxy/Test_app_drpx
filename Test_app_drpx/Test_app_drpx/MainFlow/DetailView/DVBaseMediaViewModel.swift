//
//  DVBaseMediaViewModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Foundation
import Combine

protocol DVBaseMediaViewModel {
    
    var setDataAction: PassthroughSubject<Data, Never> { get }
    var viewState: CurrentValueSubject<ViewState, Never> { get }
    var viewButtonAction: PassthroughSubject<DVButtonType, Never> { get }
    var filePath: String { get }
    var model: DVBaseMediaModel { get set }
    
    init(model: DVBaseMediaModel)
    
}

extension DVBaseMediaViewModel {
    
    var setDataAction: PassthroughSubject<Data, Never> {
        model.setDataAction
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
    
}
