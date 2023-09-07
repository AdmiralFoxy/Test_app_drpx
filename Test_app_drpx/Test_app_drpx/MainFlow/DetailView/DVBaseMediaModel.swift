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
    var fileInfo: CurrentValueSubject<MediaFile?, Never> { get }
    
    var filePath: FilePath { get set }
    var dropboxService: DropboxServiceProtocol { get set }
    
    func loadFileData(_ path: FilePath) -> AnyPublisher<Data, Error>
    
    init(
        parent: NavigationNode?,
        path: FilePath,
        dropboxService: DropboxServiceProtocol
    )
    
}

extension DVBaseMediaModel {
    
    func loadFileData(_ path: FilePath) -> AnyPublisher<Data, Error> {
        viewState.send(.loading)
        
        return dropboxService.downloadFile(path: path.path)
            .flatMap { fileData -> AnyPublisher<Data, Error> in
                if let file = fileData, let data = fileData?.data {
                    
                    fileInfo.send(file)
                    setDataAction.send(data)
                    viewState.send(.onSuccess)
                    
                    return Just(data)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    let error = CustomError.unknownError
                    
                    viewState.send(.onFailure(error.localizedDescription))
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
}
