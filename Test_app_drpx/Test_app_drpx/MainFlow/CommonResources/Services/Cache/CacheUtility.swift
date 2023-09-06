//
//  CacheUtility.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 07/09/2023.
//

import Cache

final class CacheUtility<Key: Hashable, Value: Codable> {
    
    private let diskConfig = DiskConfig(name: "MyDiskCache", expiry: .seconds(600), maxSize: 100_000_000)
    private let memoryConfig = MemoryConfig(expiry: .never, countLimit: 50, totalCostLimit: 100_000_000)
    
    private let storage: Storage<Key, Value>?
    
    init() {
        storage = try? Storage(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: Value.self)
        )
    }
    
    func saveToCache(key: Key, value: Value, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try storage?.setObject(value, forKey: key)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func getFromCache(key: Key, type: Value.Type, completion: @escaping (Result<Value, Error>) -> Void) {
        do {
            if let object = try storage?.object(forKey: key) {
                completion(.success(object))
            } else {
                completion(.failure(CacheError.notFound))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func removeCache(key: Key, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try storage?.removeObject(forKey: key)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    enum CacheError: Error {
        case notFound
    }
    
}

extension CacheUtility where Key == String, Value == MediaFile {
    
    func saveMediaFile(path: String, mediaFile: MediaFile, completion: @escaping (Result<Void, Error>) -> Void) {
        saveToCache(key: path, value: mediaFile, completion: completion)
    }
    
    func getMediaFile(path: String, completion: @escaping (Result<MediaFile, Error>) -> Void) {
        getFromCache(key: path, type: MediaFile.self, completion: completion)
    }
    
}
