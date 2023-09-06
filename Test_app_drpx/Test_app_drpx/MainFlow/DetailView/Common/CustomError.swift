//
//  CustomError.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Foundation

enum CustomError: Error {
    
    case selfDeallocated
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .selfDeallocated:
            return "The instance was deallocated before the operation could complete."
            
        case .unknownError:
            return "An unknown error occurred."
        }
    }
    
}
