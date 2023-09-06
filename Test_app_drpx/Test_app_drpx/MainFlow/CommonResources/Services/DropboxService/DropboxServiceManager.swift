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
    
    private let cursorSubject = CurrentValueSubject<String?, Never>(nil)
    private let hasMoreSubject = CurrentValueSubject<Bool, Never>(true)
    
    private var cursor: String?
    private var hasMore: Bool = true
    
    private var authorizedClient: DropboxClient? {
        DropboxClientsManager.authorizedClient
    }
    
    func downloadFile(path: String) -> AnyPublisher<MediaFile?, Error> {
        Deferred {
            Future<MediaFile?, Error> { [weak self] promise in
                self?.authorizedClient?.files.download(path: path).response { response, error in
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
    
    func fetchNextPage() -> AnyPublisher<[Files.Metadata]?, Error> {
        Deferred {
            Future<[Files.Metadata]?, Error> { [weak self] promise in
                guard let self = self else {
                    promise(.failure(CustomError.selfIsNil))
                    return
                }
                
                let completion: (Files.ListFolderResult?, CallError<Files.ListFolderError>?, @escaping ([Files.Metadata]?, Error?) -> Void) -> Void = { response, error, completion in
                    if let result = response {
                        self.cursorSubject.send(result.cursor)
                        completion(result.entries, nil)
                    } else if let error = error {
                        completion(nil, error as? Error)
                    }
                }
                
                if let cursor = try? self.cursorSubject.value, cursor != nil {
                    self.authorizedClient?.files.listFolderContinue(cursor: cursor).response { response, error in
                        completion((response, error) { entries, error in
                            if let error = error {
                                promise(.failure(error))
                            } else {
                                promise(.success(entries))
                            }
                        })
                    }
                } else {
                    self.authorizedClient?.files.listFolder(path: "", limit: 6).response { response, error in
                        completion(response, error, { entries, error in
                            if let error = error {
                                promise(.failure(error))
                            } else {
                                promise(.success(entries))
                            }
                        })
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func downloadPreview(path: String) -> AnyPublisher<UIImage?, Error> {
        Deferred {
            Future<UIImage?, Error> { [weak self] promise in
                self?.authorizedClient?.files.getThumbnailV2(
                    resource: .path(path),
                    format: .jpeg,
                    size: .w640h480,
                    mode: .bestfit
                ).response { response, error in
                    if let (_, data) = response {
                        let image = UIImage(data: data)
                        promise(.success(image))
                    } else if let error = error {
                        print("Error downloading preview: \(error)")
                        promise(.failure(error as? Error ?? CustomError.unknownError))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func processResult(
        result: Files.ListFolderResult?,
        initialError: CallError<Files.ListFolderError>?,
        continueError: CallError<Files.ListFolderContinueError>?,
        completion: ([Files.Metadata]?, Error?) -> Void
    ) {
        if let result = result {
            self.cursorSubject.send(result.cursor)
            self.hasMoreSubject.send(result.hasMore)
            completion(result.entries, nil)
        } else if let error = initialError {
            completion(nil, error as? Error)
        } else if let error = continueError {
            completion(nil, error as? Error)
        } else {
            completion(nil, CustomError.unknownError)
        }
    }

    
    func hasMoreFiles() -> Bool {
        return hasMore
    }
    
}
