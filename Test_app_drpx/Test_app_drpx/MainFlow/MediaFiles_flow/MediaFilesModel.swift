//
//  MediaFilesModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Foundation
import Combine
import SwiftyDropbox

import Foundation
import Combine
import SwiftyDropbox

final class MediaFilesModel {
    
    // MARK: - properties
    
    let mediaFiles = CurrentValueSubject<[MediaFile], Never>([])
    let viewState = CurrentValueSubject<ViewState, Never>(.idle)
    let fetchMoreFilesAction = PassthroughSubject<Void, Never>()
    
    private let dropboxService: DropboxServiceManager
    private var cursor: String?
    private var hasMore = true
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: initialize
    
    init(dropboxService: DropboxServiceManager) {
        self.dropboxService = dropboxService
        
        setupBindings()
        fetchMoreFilesAction.send(())
    }
    
}

// MARK: - helper methods

private extension MediaFilesModel {
    
    func setupBindings() {
        fetchMoreFilesAction
            .sink(receiveValue: fetchMediaFiles)
            .store(in: &cancellables)
    }
    
    // MARK: fetch files
    
    func fetchMediaFiles() {
        print("### Fetching media files started.")
        
        if !hasMore {
            print("### No more files to fetch.")
            return
        }
        
        viewState.send(.loading)
        
        if let cursor = cursor {
            fetchMoreMediaFiles(with: cursor)
        } else {
            fetchInitialMediaFiles()
        }
    }
    
    func fetchInitialMediaFiles() {
        let client = dropboxService.authorizedClient
        
        client?.files.listFolder(path: "").response { [weak self] response, error in
            self?.processMediaFilesResponse(response: response, error: error as? Error)
        }
    }
    
    func fetchMoreMediaFiles(with cursor: String) {
        print("### Fetching more media files with cursor.")
        
        let client = dropboxService.authorizedClient
        
        client?.files.listFolderContinue(cursor: cursor).response { [weak self] response, error in
            self?.processMediaFilesResponse(response: response, error: error as? Error)
        }
    }
    
    func processMediaFilesResponse(response: Files.ListFolderResult?, error: Error?) {
        if let error = error {
            print("### Error fetching media files: \(error)")
            self.viewState.send(.onFailure(error.localizedDescription))
            return
        }
        
        guard let result = response else {
            print("### Result is nil, exiting.")
            return
        }
        
        print("### Received media files.")
        print("### Result description: \(result.description)")
        print("### File paths: \(result.entries.map { $0.pathDisplay })")
        
        self.cursor = result.cursor
        self.hasMore = result.hasMore
        
        let newFiles = result.entries.compactMap { entry in
            print("### Entry description: \(entry.description)")
            if let file = entry as? Files.FileMetadata {
                print("### Processing file: \(file.name)")
                return MediaFile(name: file.name, path: file.pathLower ?? "")
            }
            return nil
        }
        
        print("### Sending fetched media files to the subscriber.")
        
        var currentFiles = try? self.mediaFiles.value
        currentFiles?.append(contentsOf: newFiles)
        self.mediaFiles.send(currentFiles ?? [])
    }
    
}
