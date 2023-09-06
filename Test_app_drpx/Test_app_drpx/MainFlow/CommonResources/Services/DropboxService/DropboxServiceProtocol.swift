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
    
    func downloadFile(path: String) -> AnyPublisher<MediaFile?, Error>
    func downloadPreview(path: String) -> AnyPublisher<UIImage?, Error>
    func fetchNextPage() -> AnyPublisher<[Files.Metadata]?, Error>
    func authorizeFromController(controller: UIViewController)
    func hasMoreFiles() -> Bool
    
}
