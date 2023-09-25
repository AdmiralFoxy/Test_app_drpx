//
//  ImageViewModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 04/09/2023.
//

import Foundation
import Combine
import UIKit

final class ImageViewModel: DVBaseMediaViewModel {
    
    var model: DVBaseMediaModel
    
    init(model: DVBaseMediaModel) {
        self.model = model
    }
    
}
