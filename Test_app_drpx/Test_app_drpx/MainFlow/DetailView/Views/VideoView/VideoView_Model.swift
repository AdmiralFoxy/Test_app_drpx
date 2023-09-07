//
//  VideoView_Model.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Combine
import UIKit

final class VideoView_Model: NavigationNode, DVBaseMediaModel {
    
    // MARK: properties
    
    var viewButtonAction: PassthroughSubject<DVButtonType, Never> = .init()
    var setDataAction: PassthroughSubject<Data, Never> = .init()
    var viewState: CurrentValueSubject<ViewState, Never> = .init(.idle)
    var fileInfo = CurrentValueSubject<MediaFile?, Never>(nil)
    
    var filePath: FilePath
    var dropboxService: DropboxServiceProtocol
    
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

extension VideoView_Model {
    
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
