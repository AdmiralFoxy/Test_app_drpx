//
//  MainFilesCellInfoModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Combine
import UIKit

final class MainFilesCellInfoModel {
    
    let cellTapAction: PassthroughSubject<FilePath, Never>
    let moveFileAction: PassthroughSubject<FilePath, Never>
    let deleteFileAction: PassthroughSubject<FilePath, Never>
    
    let setImgPreviewAction = PassthroughSubject<UIImage, Never>()
    let cancelImgLoadingAction = PassthroughSubject<Void, Never>()
    
    let title: String
    let filePath: String
    
    private var imageLoadCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    private let cacheDropboxService: DropboxCacheProtocol
    
    init(
        title: String,
        filePath: String,
        cellTapAction: PassthroughSubject<FilePath, Never>,
        moveFileAction: PassthroughSubject<FilePath, Never>,
        deleteFileAction: PassthroughSubject<FilePath, Never>,
        cacheDropboxService: DropboxCacheProtocol
    ) {
        self.cellTapAction = cellTapAction
        self.moveFileAction = moveFileAction
        self.deleteFileAction = deleteFileAction
        
        self.cacheDropboxService = cacheDropboxService
        
        self.title = title
        self.filePath = filePath
        
        setupBindings()
    }
    
}

private extension MainFilesCellInfoModel {
    
    func setupBindings() {
        cancelImgLoadingAction
            .sink { [weak self] in
                self?.imageLoadCancellable?.cancel()
            }
            .store(in: &cancellables)
        
        imageLoadCancellable = cacheDropboxService.downloadPreview(path: filePath)
            .compactMap { $0 }
            .call(self, type(of: self).setupImage)
    }
    
    func setupImage(_ data: Data) {
        if let image = UIImage(data: data) {
            setImgPreviewAction.send(image)
        }
    }
    
}
