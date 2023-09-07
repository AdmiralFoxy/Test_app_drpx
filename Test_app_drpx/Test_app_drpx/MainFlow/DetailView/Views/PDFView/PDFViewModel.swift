//
//  PDFViewModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Foundation
import Combine

final class PDFViewModel: DVBaseMediaViewModel {
    
    // MARK: properties
    
    var model: DVBaseMediaModel
    
    // MARK: initialize
    
    init(model: DVBaseMediaModel) {
        self.model = model
    }
    
}
