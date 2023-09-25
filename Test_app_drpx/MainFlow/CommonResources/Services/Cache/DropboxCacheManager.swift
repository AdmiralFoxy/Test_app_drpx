//
//  DropboxCacheManager.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Cache
import Combine
import UIKit
import SwiftyDropbox

protocol DropboxCacheProtocol {
    
    func downloadFile(path: String) -> AnyPublisher<MediaFile?, CustomError>
    func downloadPreview(path: String) -> AnyPublisher<Data?, Never>
    
}

final class DropboxCacheManager: DropboxCacheProtocol {
    
    let mediaFileCache = CacheUtility<String, MediaFile>()
    let paginationFilesCache = CacheUtility<String, MediaFile>()
    let dataFileCache = CacheUtility<String, Data>()
    
    private let dropboxServiceManager: DropboxServiceManager
    private var cancellables = Set<AnyCancellable>()
    
    init(dropboxServiceManager: DropboxServiceManager) {
        self.dropboxServiceManager = dropboxServiceManager
    }
    
    func downloadFile(path: String) -> AnyPublisher<MediaFile?, CustomError> {
        Future<MediaFile?, Error> { [weak self] promise in
            guard let self = self else { return }
            
            mediaFileCache.getFromCache(key: path, type: MediaFile.self) { result in
                switch result {
                case .success(let cachedData):
                    promise(.success(cachedData))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .catch { _ in Just(nil) }
        .flatMap { [weak self] cachedData -> AnyPublisher<MediaFile?, CustomError> in
            guard let self = self else {
                return Fail<MediaFile?, CustomError>(error: CustomError.selfIsNil)
                    .eraseToAnyPublisher()
            }
            
            let cachedPublisher = Just(cachedData)
                .setFailureType(to: CustomError.self)
                .eraseToAnyPublisher()
            
            let apiPublisher = self.dropboxServiceManager
                .downloadFile(path: path)
                .handleEvents(receiveOutput: { mediaFile in
                    if let mediaFile = mediaFile {
                        self.mediaFileCache.saveToCache(key: path, value: mediaFile) { result in
                            switch result {
                            case .failure(let error):
                                print("Caching error: \(error)")
                                
                            case .success:
                                break
                            }
                        }
                    }
                })
                .mapError { error in CustomError.unknownError }
                .eraseToAnyPublisher()
            
            return Publishers
                .Concatenate(prefix: cachedPublisher, suffix: apiPublisher)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    func downloadPreview(path: String) -> AnyPublisher<Data?, Never> {
        let cacheKey = "preview_\(path)"
        
        return Future<Data?, Error> { [weak self] promise in
            guard let self = self else { return }
            
            self.dataFileCache
                .getFromCache(key: cacheKey, type: Data.self) { result in
                    switch result {
                    case .success(let cachedData):
                        promise(.success(cachedData))
                        
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .catch { _ in Just(nil) }
        .flatMap { [weak self] cachedImage -> AnyPublisher<Data?, Never> in
            guard let self = self else {
                return Just(nil).eraseToAnyPublisher()
            }
            
            let cachedPublisher = Just(cachedImage).eraseToAnyPublisher()
            let networkData = self.dropboxServiceManager
                .downloadPreview(path: path)
                .replaceError(with: nil)
                .share()
            
            networkData
                .handleEvents(receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.dataFileCache.removeCache(key: cacheKey) { result in
                            switch result {
                            case .failure(let error):
                                print("Error removing cache: \(error)")
                            case .success:
                                break
                            }
                        }
                    }
                })
                .compactMap { $0 }
                .sink { [weak self] data in
                    self?.dataFileCache.saveToCache(key: cacheKey, value: data) { result in
                        switch result {
                        case .failure(let error):
                            print("Caching error: \(error)")
                        case .success:
                            break
                        }
                    }
                }
                .store(in: &self.cancellables)
            
            return cachedPublisher.append(networkData).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
}
