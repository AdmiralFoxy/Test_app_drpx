//
//  DropboxServiceProtocol.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Combine
import UIKit
import SwiftyDropbox

protocol DropboxServiceProtocol {
    
    var cursorSubjects: CurrentValueSubject<String?, Never> { get }
    var hasMoreSubjects: CurrentValueSubject<Bool, Never> { get }
    
    func downloadFile(path: String) -> AnyPublisher<MediaFile?, Error>
    func downloadPreview(path: String) -> AnyPublisher<Data?, Error>
    func fetchNextPage() -> AnyPublisher<Files.ListFolderResult?, Error>
    func authorizeFromController(controller: UIViewController)
    func hasMoreFiles() -> Bool
    func clearPaginationValues()
    func deleteFile(path: String) -> AnyPublisher<Void, Error>
    func moveFile(fromPath: String, toPath: String) -> AnyPublisher<Void, Error>
    
}
