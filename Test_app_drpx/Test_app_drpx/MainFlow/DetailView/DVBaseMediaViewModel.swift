//
//  DVBaseMediaViewModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Foundation
import Combine

protocol DVBaseMediaViewModel {
    
    // MARK: - properties
    
    var setDataAction: PassthroughSubject<Data, Never> { get }
    var viewState: CurrentValueSubject<ViewState, Never> { get }
    var viewButtonAction: PassthroughSubject<DVButtonType, Never> { get }
    var fileInfo: CurrentValueSubject<MediaFile?, Never> { get }
    
    var filePath: FilePath { get }
    var model: DVBaseMediaModel { get set }
    
    // MARK: initialize
    
    init(model: DVBaseMediaModel)
    
}

// MARK: - setup view model properties

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
    
    var fileInfo: CurrentValueSubject<MediaFile?, Never> {
        model.fileInfo
    }
    
    var filePath: FilePath {
        model.filePath
    }
    
}
