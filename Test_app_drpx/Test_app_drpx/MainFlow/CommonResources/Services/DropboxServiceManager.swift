//
//  DropboxServiceManager.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Foundation
import SwiftyDropbox
import UIKit

final class DropboxServiceManager {
    
    private var client: DropboxClient
    private var cursor: String?
    private var hasMore: Bool = true
    
    var authorizedClient: DropboxClient? {
        return DropboxClientsManager.authorizedClient
    }
    
    init(client: DropboxClient) {
        self.client = client
    }
    
    func downloadFile(path: String, completion: @escaping (Data?, Error?) -> Void) {
        client.files.download(path: path).response { (response, error) in
            if let (metadata, data) = response {
                print("Metadata: \(metadata)")
                completion(data, nil)
            } else if let error = error {
                print("Error downloading file: \(error)")
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: error.description]))
            }
        }
    }
    
    func authorizeFromController(controller: UIViewController) {
        let scopeRequest = ScopeRequest(
            scopeType: .user,
            scopes: ["file_requests.read", "files.content.read", "files.metadata.read", "account_info.read"],
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
    
    func fetchNextPage(completion: @escaping ([Files.Metadata]?, Error?) -> Void) {
        if let cursor = cursor {
            client.files.listFolderContinue(cursor: cursor).response { [weak self] (result, error) in
                self?.processContinueResult(result: result, error: error, completion: completion)
            }
        } else {
            client.files.listFolder(path: "").response { [weak self] (result, error) in
                self?.processInitialResult(result: result, error: error, completion: completion)
            }
        }
    }
    
    private func processInitialResult(
        result: Files.ListFolderResult?,
        error: CallError<Files.ListFolderError>?,
        completion: ([Files.Metadata]?, Error?) -> Void
    ) {
        if let result = result {
            self.cursor = result.cursor
            self.hasMore = result.hasMore
            completion(result.entries, nil)
        } else if let error = error {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: error.description]))
        }
    }
    
    private func processContinueResult(
        result: Files.ListFolderResult?,
        error: CallError<Files.ListFolderContinueError>?,
        completion: ([Files.Metadata]?, Error?) -> Void
    ) {
        if let result = result {
            self.cursor = result.cursor
            self.hasMore = result.hasMore
            completion(result.entries, nil)
        } else if let error = error {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: error.description]))
        }
    }
    
    func hasMoreFiles() -> Bool {
        return hasMore
    }
    
}
