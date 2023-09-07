//
//  ImageView_Model.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 04/09/2023.
//

import Foundation
import Combine
import UIKit

final class ImageView_Model: NavigationNode, DVBaseMediaModel {
    
    var viewButtonAction: PassthroughSubject<DVButtonType, Never> = .init()
    var setDataAction: PassthroughSubject<Data, Never> = .init()
    var viewState: CurrentValueSubject<ViewState, Never> = .init(.idle)
    var fileInfo = CurrentValueSubject<MediaFile?, Never>(nil)
    
    var dropboxService: DropboxServiceProtocol
    var filePath: FilePath
    
    private var cancellables = Set<AnyCancellable>()
    
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

private extension ImageView_Model {
    
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
