//
//  DropboxServiceMock.swift
//  Test_app_drpxTests
//
//  Created by Stanislav Avramenko on 07/09/2023.
//

import UIKit
import Combine
import SwiftyDropbox
@testable import Test_app_drpx

final class DropboxServiceMock: DropboxServiceProtocol {
    
    var cursorSubjects: CurrentValueSubject<String?, Never>
    var hasMoreSubjects: CurrentValueSubject<Bool, Never>
    
    private let _downloadFileResult: Result<MediaFile?, Error>
    private let _downloadPreviewResult: Result<Data?, Error>
    private let _fetchNextPageResult: Result<Files.ListFolderResult?, Error>
    private let _deleteFile: AnyPublisher<Void, Error>
    private let _moveFile: AnyPublisher<Void, Error>
    
    init(
        downloadFileResult: Result<MediaFile?, Error> = .success(nil),
        downloadPreviewResult: Result<Data?, Error> = .success(nil),
        fetchNextPageResult: Result<Files.ListFolderResult?, Error> = .success(nil),
        hasMoreSubjects: CurrentValueSubject<Bool, Never> = .init(false),
        cursorSubjects: CurrentValueSubject<String?, Never> = .init(nil),
        deleteFile: AnyPublisher<Void, Error> = Future {
            promise in promise(.success(()))
        }.eraseToAnyPublisher(),
        moveFile: AnyPublisher<Void, Error> = Future {
            promise in promise(.success(()))
        }.eraseToAnyPublisher()
    ) {
        self._downloadFileResult = downloadFileResult
        self._downloadPreviewResult = downloadPreviewResult
        self._fetchNextPageResult = fetchNextPageResult
        self.hasMoreSubjects = hasMoreSubjects
        self.cursorSubjects = cursorSubjects
        self._deleteFile = deleteFile
        self._moveFile = moveFile
    }
    
    func deleteFile(path: String) -> AnyPublisher<Void, Error> {
        _deleteFile
    }
    
    func moveFile(fromPath: String, toPath: String) -> AnyPublisher<Void, Error> {
        _moveFile
    }
    
    func downloadFile(path: String) -> AnyPublisher<MediaFile?, Error> {
        return Future { promise in
            switch self._downloadFileResult {
            case .success(let mediaFile):
                promise(.success(mediaFile))
            case .failure(let error):
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func downloadPreview(path: String) -> AnyPublisher<Data?, Error> {
        return Future { promise in
            switch self._downloadPreviewResult {
            case .success(let data):
                promise(.success(data))
            case .failure(let error):
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchNextPage() -> AnyPublisher<Files.ListFolderResult?, Error> {
        return Future { promise in
            switch self._fetchNextPageResult {
            case .success(let filesListFolderResult):
                promise(.success(filesListFolderResult))
            case .failure(let error):
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func authorizeFromController(controller: UIViewController) { }
    
    func hasMoreFiles() -> Bool {
        return self.hasMoreSubjects.value
    }
    
    func clearPaginationValues() {
        cursorSubjects.send(nil)
        hasMoreSubjects.send(false)
    }
    
}
