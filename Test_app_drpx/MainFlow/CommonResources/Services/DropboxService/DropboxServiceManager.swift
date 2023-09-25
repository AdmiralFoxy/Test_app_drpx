//
//  DropboxServiceManager.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Combine
import SwiftyDropbox
import UIKit

final class DropboxServiceManager: DropboxServiceProtocol {
    
    var cursorSubjects: CurrentValueSubject<String?, Never> {
        _cursorSubject
    }
    var hasMoreSubjects: CurrentValueSubject<Bool, Never> {
        _hasMoreSubject
    }
    
    private let  _cursorSubject = CurrentValueSubject<String?, Never>(nil)
    private let _hasMoreSubject = CurrentValueSubject<Bool, Never>(true)
    
    var authClient: DropboxClient? {
        DropboxClientsManager.authorizedClient
    }
    
    func clearPaginationValues() {
        _cursorSubject.send(nil)
        _hasMoreSubject.send(true)
    }
    
    func downloadFile(path: String) -> AnyPublisher<MediaFile?, Error> {
        Deferred {
            Future<MediaFile?, Error> { [weak self] promise in
                self?.authClient?.files.download(path: path).response { response, error in
                    if let (metadata, data) = response {
                        let fileData = MediaFile.setupMetadata(data: data, metadata: metadata)
                        promise(.success(fileData))
                    } else if let error = error {
                        print("Error downloading file: \(error)")
                        promise(.failure(error as? Error ?? CustomError.unknownError))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func authorizeFromController(controller: UIViewController) {
        let scope = ["file_requests.read", "files.content.read", "files.metadata.read", "account_info.read"]
        let scopeRequest = ScopeRequest(
            scopeType: .user,
            scopes: scope,
            includeGrantedScopes: false
        )
        
        DropboxClientsManager.authorizeFromControllerV2(
            UIApplication.shared,
            controller: controller,
            loadingStatusDelegate: nil,
            openURL: { (url: URL) -> Void in
                UIApplication.shared.open(url, options: [:])
            },
            scopeRequest: scopeRequest
        )
    }
    
    func fetchNextPage() -> AnyPublisher<Files.ListFolderResult?, Error> {
        return Deferred {
            Future<Files.ListFolderResult?, Error> { [weak self] promise in
                guard let self = self else {
                    promise(.failure(CustomError.selfIsNil))
                    return
                }
                
                let completion: (Files.ListFolderResult?, CallError<Files.ListFolderError>?, @escaping (Files.ListFolderResult?, Error?) -> Void) -> Void = { response, error, completion in
                    if let result = response {
                        self._cursorSubject.send(result.cursor)
                        self._hasMoreSubject.send(result.hasMore)
                        completion(result, nil)
                    } else if let error = error {
                        self._cursorSubject.send(nil)
                        self._hasMoreSubject.send(false)
                        completion(nil, error as? Error)
                    }
                }
                
                if let cursor = self._cursorSubject.value {
                    self.authClient?.files.listFolderContinue(cursor: cursor).response { response, error in
                        if let result = response {
                            self._cursorSubject.send(result.cursor)
                            self._hasMoreSubject.send(result.hasMore)
                            
                            completion(response, nil) { result, error in
                                if let error = error {
                                    promise(.failure(error))
                                } else {
                                    promise(.success(result))
                                }
                            }
                        } else if let error = error {
                            self._cursorSubject.send(nil)
                            self._hasMoreSubject.send(false)
                            completion(response, nil) { _, _ in
                                promise(.failure(CustomError.unknownError))
                            }
                        }
                    }
                    
                } else {
                    self.authClient?.files.listFolder(path: "", limit: 6).response { response, error in
                        completion(response, nil) { result, error in
                            if let error = error {
                                promise(.failure(error))
                            } else {
                                promise(.success(result))
                            }
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func downloadPreview(path: String) -> AnyPublisher<Data?, Error> {
        Deferred {
            Future<Data?, Error> { [weak self] promise in
                self?.authClient?.files.getThumbnail(
                    path: path,
                    format: .jpeg,
                    size: .w640h480,
                    mode: .bestfit
                ).response { response, error in
                    if let (_, data) = response {
                        promise(.success(data))
                        
                    } else if let error = error {
                        print("Error downloading preview: \(error)")
                        promise(.failure(error as? Error ?? CustomError.unknownError))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteFile(path: String) -> AnyPublisher<Void, Error> {
        Deferred {
            Future<Void, Error> { [weak self] promise in
                self?.authClient?.files.deleteV2(path: path).response { response, error in
                    if let _ = response {
                        promise(.success(()))
                    } else if let error = error {
                        print("Error deleting file: \(error)")
                        promise(.failure(error as? Error ?? CustomError.unknownError))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func moveFile(fromPath: String, toPath: String) -> AnyPublisher<Void, Error> {
        Deferred {
            Future<Void, Error> { [weak self] promise in
                self?.authClient?.files.moveV2(fromPath: fromPath, toPath: toPath).response { response, error in
                    if let _ = response {
                        promise(.success(()))
                    } else if let error = error {
                        print("Error moving file: \(error)")
                        promise(.failure(error as? Error ?? CustomError.unknownError))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func hasMoreFiles() -> Bool {
        return _hasMoreSubject.value
    }
    
}
