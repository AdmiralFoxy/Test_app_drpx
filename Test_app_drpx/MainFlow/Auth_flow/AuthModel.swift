//
//  AuthModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 01/09/2023.
//

import Foundation
import SwiftyDropbox
import Combine
import UIKit

final class AuthModel {
    
    // MARK: properties
    
    let loginAction = PassthroughSubject<AuthViewController, Never>()
    let viewState = CurrentValueSubject<ViewState, Never>(.idle)
    
    private var cancellables = Set<AnyCancellable>()
    private let dropboxService: DropboxServiceManager
    
    // MARK: initialize
    
    init(dropboxService: DropboxServiceManager) {
        self.dropboxService = dropboxService
        
        setupBindings()
    }
    
}

// MARK: - setup model

private extension AuthModel {
    
    func setupBindings() {
        loginAction
            .call(self, type(of: self).loginActionHandler)
            .store(in: &cancellables)
    }
    
    func loginActionHandler(_ controller: UIViewController) {
        dropboxService.authorizeFromController(controller: controller)
    }
    
}
