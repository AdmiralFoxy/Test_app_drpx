//
//  PDFModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Foundation
import UIKit
import Combine

final class PDFModel: NavigationNode, DVBaseMediaModel {
    
    // MARK: properties
    
    var viewButtonAction = PassthroughSubject<DVButtonType, Never>()
    var setDataAction = PassthroughSubject<Data, Never>()
    var viewState = CurrentValueSubject<ViewState, Never>(.idle)
    var fileInfo = CurrentValueSubject<MediaFile?, Never>(nil)
    
    var dropboxService: DropboxServiceProtocol
    var filePath: FilePath
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: initialize
    
    init(
        parent: NavigationNode?,
        path: FilePath,
        dropboxService: DropboxServiceProtocol
    ) {
        self.filePath = path
        self.dropboxService = dropboxService
        
        super.init(parent: parent)
        
        setupBindings()
    }
    
}

// MARK: setup bindings

private extension PDFModel {
    
    func setupBindings() {
        viewButtonAction
            .call(self, type(of: self).actionHandle)
            .store(in: &cancellables)
        
        loadFileData(filePath)
            .catch { [weak self] error -> Just<Data> in
                self?.viewState.send(.onFailure(error.localizedDescription))
                
                return Just<Data>(Data())
            }
            .sink { [weak self] dataValue in
                guard let self = self else { return }
                
                if !dataValue.isEmpty {
                    self.setDataAction.send(dataValue)
                }
            }
            .store(in: &cancellables)
    }
    
    func actionHandle(_ type: DVButtonType) {
        switch type {
        case .info(let file):
            raise(event: AppMainEvents.infoView(file: file))
            
        case .close:
            raise(event: AppMainEvents.mainFiles)
        }
    }
    
}
