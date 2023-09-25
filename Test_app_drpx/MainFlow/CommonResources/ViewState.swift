//
//  ViewState.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 01/09/2023.
//

import Foundation

enum ViewState {
    
    case loading
    case idle
    case onSuccess
    case onFailure(String)
    
}

// MARK: integrate equatable

extension ViewState: Equatable {
    
    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
            (.idle, .idle),
            (.onSuccess, .onSuccess):
            return true
            
        case (.onFailure(let lhsMessage), .onFailure(let rhsMessage)):
            return lhsMessage == rhsMessage
            
        default:
            return false
        }
    }
    
}
