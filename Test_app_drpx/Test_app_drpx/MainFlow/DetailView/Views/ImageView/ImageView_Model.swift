//
//  ImageView_Model.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 04/09/2023.
//

import Foundation
import Combine
import UIKit

final class ImageView_Model: NavigationNode {
    
    let viewButtonAction = PassthroughSubject<DVButtonType, Never>()
    let setImageAction = PassthroughSubject<UIImage, Never>()
    let viewState = CurrentValueSubject<ViewState, Never>(.idle)
    let filePath: String
    
    private var cancellables = Set<AnyCancellable>()
    private let dropboxService: DropboxServiceManager
    
    init(
        parent: NavigationNode?,
        path: String,
        dropboxService: DropboxServiceManager
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
    }
    
    func actionHandle(_ type: DVButtonType) {
        switch type {
        case .info(let path):
            raise(event: AppMainEvents.infoView(path: path))
            
        case .close:
            raise(event: AppMainEvents.mainFiles)
        }
    }
    
    func loadFileData(_ path: String) {
        viewState.send(.loading)
        
        dropboxService.downloadFile(path: path) { [weak self] data, error in
            guard let self = self else { return }
            
            if let data = data, let image = UIImage(data: data) {
                self.setImageAction.send(image)
                self.viewState.send(.onSuccess)
                
            } else if let error = error {
                let message = error.localizedDescription
                
                self.viewState.send(.onFailure(message))
            }
        }
        
    }
    
}
