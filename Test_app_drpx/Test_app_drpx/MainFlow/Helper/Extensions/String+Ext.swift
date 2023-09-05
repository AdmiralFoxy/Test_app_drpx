//
//  String+Ext.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 01/09/2023.
//

import Foundation
import UIKit

extension String {
    
    var isNotEmpty: Bool {
        !self.isEmpty
    }
    
}

extension Optional {
    
    var wrapNilToString: String {
        switch self {
        case let string as String:
            return string
        default:
            return ""
        }
    }
    
}
