//
//  BaseMediaModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Foundation
import Combine

protocol DVBaseMediaModel {
    
    var viewButtonAction: PassthroughSubject<DVButtonType, Never> { get }
    var setDataAction: PassthroughSubject<Data, Never> { get }
    var viewState: CurrentValueSubject<ViewState, Never> { get }
    
    var filePath: FilePath { get set }
    var fileInfo: MediaFile? { get set }
    var dropboxService: DropboxServiceManager { get set }
    
    func loadFileData(_ path: FilePath) -> AnyPublisher<Data, Error>
    
    init(
        parent: NavigationNode?,
        path: FilePath,
        dropboxService: DropboxServiceManager
    )
    
}

extension DVBaseMediaModel {
    
    func loadFileData(_ path: FilePath) -> AnyPublisher<Data, Error> {
        viewState.send(.loading)
        
        return dropboxService.downloadFile(path: path.path)
            .flatMap { fileData -> AnyPublisher<Data, Error> in
                if let data = fileData?.data {
                    self.setDataAction.send(data)
                    self.viewState.send(.onSuccess)
                    
                    return Just(data)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    let error = CustomError.unknownError
                    
                    self.viewState.send(.onFailure(error.localizedDescription))
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
}