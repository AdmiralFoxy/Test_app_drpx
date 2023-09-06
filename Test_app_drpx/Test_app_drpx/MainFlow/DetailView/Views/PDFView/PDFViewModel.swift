//
//  PDFViewModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Foundation
import Combine

final class PDFViewModel: DVBaseMediaViewModel {
    
    var model: DVBaseMediaModel
    
    init(model: DVBaseMediaModel) {
        self.model = model
    }
    
}
