//
//  DropboxCacheServiceMock.swift
//  Test_app_drpxTests
//
//  Created by Stanislav Avramenko on 07/09/2023.
//

import UIKit
import Combine
@testable import Test_app_drpx

class DropboxCacheServiceMock: DropboxCacheProtocol {
    
    private let _downloadFileResult: Result<MediaFile?, CustomError>
    private let _downloadPreviewResult: Result<Data?, Never>
    
    init(
        downloadFileResult: Result<MediaFile?, CustomError> = .success(nil),
        downloadPreviewResult: Result<Data?, Never> = .success(nil)
    ) {
        self._downloadFileResult = downloadFileResult
        self._downloadPreviewResult = downloadPreviewResult
    }
    
    func downloadFile(path: String) -> AnyPublisher<MediaFile?, CustomError> {
        return Future<MediaFile?, CustomError> { [weak self] promise in
            promise(self?._downloadFileResult ?? .success(nil))
        }
        .eraseToAnyPublisher()
    }
    
    func downloadPreview(path: String) -> AnyPublisher<Data?, Never> {
        return Future<Data?, Never> { [weak self] promise in
            promise(self?._downloadPreviewResult ?? .success(nil))
        }
        .eraseToAnyPublisher()
    }
    
}
