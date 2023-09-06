//
//  MediaFilesModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Foundation
import Combine
import SwiftyDropbox

final class MediaFilesModel: NavigationNode {
    
    // MARK: - properties
    
    let mediaFiles = CurrentValueSubject<[MediaFile], Never>([])
    let viewState = CurrentValueSubject<ViewState, Never>(.idle)
    let fetchMoreFilesAction = PassthroughSubject<Void, Never>()
    
    let cellTapAction = PassthroughSubject<FilePath, Never>()
    let cellMoveFileAction = PassthroughSubject<Void, Never>()
    let cellDeleteFileAction = PassthroughSubject<Void, Never>()
    
    let dropboxService: DropboxServiceManager
    let dropboxCacheService: DropboxCacheProtocol
    
    private(set) var loadFilesPubl: AnyPublisher<[Files.Metadata]?, Error>?
    private var cursor: String?
    private var hasMore = true
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: initialize
    
    init(
        parent: NavigationNode?,
        dropboxService: DropboxServiceManager,
        dropboxCacheService: DropboxCacheProtocol
    ) {
        self.dropboxService = dropboxService
        self.dropboxCacheService = dropboxCacheService
        
        super.init(parent: parent)
        
        setupBindings()
        fetchMoreFilesAction.send(())
    }
    
}

// MARK: - helper methods

private extension MediaFilesModel {
    
    // MARK: setup bindings
    
    func setupBindings() {
        fetchMoreFilesAction
            .sink(receiveValue: fetchMediaFiles)
            .store(in: &cancellables)
        
        cellTapAction
            .call(self, type(of: self).cellTapHandle)
            .store(in: &cancellables)
    }
    
    func cellTapHandle(path: FilePath) {
        guard let event = DetailViewEvents.getDetailViewEvent(for: path) else {
            viewState.send(.onFailure("error file format"))
            return
        }
        
        raise(event: event)
    }
    
    // MARK: fetch files
    
    func fetchMediaFiles() {
        print("### Fetching media files started.")
        
        if !hasMore {
            print("### No more files to fetch.")
            return
        }
        
        viewState.send(.loading)
        
        dropboxService.fetchNextPage()
            .call(self, type(of: self).processMediaFilesResponse)
            .store(in: &cancellables)
    }
    
    // MARK: handle loaded files
    
    func processMediaFilesResponse(response: Files.ListFolderResult?) {
        guard let result = response else {
            print("### Error fetching media files")
            viewState.send(.onFailure("Error fetching media files"))
            
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
                let media = MediaFile(
                    name: file.name,
                    path: file.pathLower ?? "",
                    clientModified: file.clientModified,
                    serverModified: file.serverModified,
                    contentHash: "",
                    id: file.id,
                    isDownloadable: file.isDownloadable,
                    size: Int(file.size),
                    data: nil
                )
                
                return media
            }
            return nil
        }
        
        print("### Sending fetched media files to the subscriber.")
        
        var currentFiles = mediaFiles.value
        
        currentFiles.append(contentsOf: newFiles)
        mediaFiles.send(currentFiles)
    }
    
}
