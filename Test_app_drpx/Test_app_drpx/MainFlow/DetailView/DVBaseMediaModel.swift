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
    
    var filePath: String { get set }
    var fileData: Data? { get set }
    var dropboxService: DropboxServiceManager { get set }
    
    func loadFileData(_ path: String) -> Future<Data, Error>
    
    init(
        parent: NavigationNode?,
        path: String,
        dropboxService: DropboxServiceManager
    )
    
}

extension DVBaseMediaModel {
    
    func loadFileData(_ path: String) -> Future<Data, Error> {
        viewState.send(.loading)
        
        return Future { promise in
            dropboxService.downloadFile(path: path) { data, error in
                if let data = data {
                    self.setDataAction.send(data)
                    self.viewState.send(.onSuccess)
                    promise(.success(data))
                    
                } else if let error = error {
                    let message = error.localizedDescription
                    self.viewState.send(.onFailure(message))
                    promise(.failure(error))
                }
            }
        }
    }
    
}
