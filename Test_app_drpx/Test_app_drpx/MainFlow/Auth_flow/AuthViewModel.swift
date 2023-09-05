//
//  AuthViewModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 01/09/2023.
//

import Foundation
import Combine

final class AuthViewModel: ObservableObject {
    
    var loginAction: PassthroughSubject<AuthViewController, Never> {
        model.loginAction
    }
    
    private let model: AuthModel
    
    init(model: AuthModel) {
        self.model = model
    }
    
}
