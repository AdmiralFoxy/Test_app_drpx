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
    func downloadPreview(path: String) -> AnyPublisher<UIImage?, Never>
    
}

final class CacheUtility {

    private let cache = NSCache<NSString, AnyObject>()

    static let shared = CacheUtility()

    private init() {}

    func saveToCache(key: String, value: AnyObject) {
        cache.setObject(value, forKey: key as NSString)
    }

    func getFromCache(key: String) -> AnyObject? {
        return cache.object(forKey: key as NSString)
    }

}

final class DropboxCacheManager: DropboxCacheProtocol {
    
    private let dropboxServiceManager: DropboxServiceManager
    private let storage: Storage<String, Data>
    private var cancellables = Set<AnyCancellable>()
    
    private let paginationDataStorage: Storage<String, [Files.Metadata]>
    
    init(dropboxServiceManager: DropboxServiceManager,
         storage: Storage<String, Data>,
         paginationDataStorage: Storage<String, [Files.Metadata]>) {
        self.dropboxServiceManager = dropboxServiceManager
        self.storage = storage
        self.paginationDataStorage = paginationDataStorage
    }
    
    func downloadFile(path: String) -> AnyPublisher<MediaFile?, CustomError> {
        let cachedPublisher = Just(CacheUtility.shared.getFromCache(key: path) as? MediaFile)
            .setFailureType(to: CustomError.self)
            .eraseToAnyPublisher()
        
        let apiPublisher = dropboxServiceManager.downloadFile(path: path)
            .handleEvents(receiveOutput: { mediaFile in
                if let mediaFile = mediaFile {
                    DispatchQueue.global(qos: .background).async {
                        CacheUtility.shared.saveToCache(key: path, value: mediaFile as AnyObject)
                    }
                }
            })
            .mapError { error in CustomError.unknownError }
            .eraseToAnyPublisher()
            
        return cachedPublisher
            .merge(with: apiPublisher)
            .eraseToAnyPublisher()
    }
    
    func downloadPreview(path: String) -> AnyPublisher<UIImage?, Never> {
        let cachedData = try? storage.object(forKey: "preview_\(path)")
        let cachedImage = cachedData.flatMap { UIImage(data: $0) }
        
        let networkData = dropboxServiceManager.downloadPreview(path: path)
            .replaceError(with: nil)
            .share()
        
        networkData
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.storage.removeObject(forKey: "preview_\(path)")
                }
            })
            .compactMap { $0?.pngData() }
            .sink { [weak self] data in
                try? self?.storage.setObject(data, forKey: "preview_\(path)")
            }
            .store(in: &cancellables)
        
        return Publishers.Concatenate(prefix: Just(cachedImage), suffix: networkData)
            .eraseToAnyPublisher()
    }
    
    func fetchNextPage() -> AnyPublisher<[Files.Metadata]?, Never> {
        // Создаем ключ на основе текущего cursor
        let cacheKey = "paginationData_\(dropboxServiceManager.cursor ?? "")"
        
        // Получаем закешированные данные
        let cachedData = try? paginationDataStorage.object(forKey: cacheKey)
        
        // Создаем паблишер для закешированных данных
        let cachePublisher = Just(cachedData).eraseToAnyPublisher()
        
        // Создаем паблишер для сетевого запроса
        let networkPublisher = dropboxServiceManager.fetchNextPage()
            .catch { _ in Just(nil) }
            .handleEvents(receiveOutput: { [weak self] newEntries in
                guard let newEntries = newEntries else { return }
                
                // Сохраняем новые данные в кеше
                try? self?.paginationDataStorage.setObject(newEntries, forKey: cacheKey)
            })
            .eraseToAnyPublisher()
        
        // Возвращаем конкатенацию паблишеров, чтобы сначала были возвращены закешированные данные, а затем - новые данные от сетевого запроса
        return cachePublisher.append(networkPublisher).eraseToAnyPublisher()
    }
    
}
