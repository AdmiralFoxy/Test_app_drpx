//
//  MainFilesCellInfoViewModel.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Foundation
import UIKit

final class MainFilesCellInfoViewModel {
    
    var title: String {
        model.title
    }
    
    var path: String {
        model.path
    }
    
    private let model: MainFilesCellInfoModel
    
    init(model: MainFilesCellInfoModel) {
        self.model = model
    }
    
}
