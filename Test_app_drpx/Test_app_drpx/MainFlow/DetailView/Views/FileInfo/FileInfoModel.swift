//
//  FileInfoModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Foundation
import Combine

final class FileInfoModel: NavigationNode {
    
    let closeButtonAction: PassthroughSubject<Void, Never> = .init()
    let fileDetail: MediaFile
    
    private var cancellables = Set<AnyCancellable>()
    
    init(parent: NavigationNode?, fileDetail: MediaFile) {
        self.fileDetail = fileDetail
        
        super.init(parent: parent)
        
        setupBindings()
    }
    
}

private extension FileInfoModel {
    
    func setupBindings() {
        closeButtonAction
            .call(self, type(of: self).actionHandle)
            .store(in: &cancellables)
    }
    
    func actionHandle() {
        raise(event: AppMainEvents.mainFiles)
    }
    
}
