//
//  DVBaseMediaViewController.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Foundation

protocol DVControllerSetup {
    
    func setupView()
    func setupBindings()
    func handleViewState(_ state: ViewState)
    
}

protocol DVButtonsAction {
    
    func closeButtonPressed()
    func infoButtonPressed()
    
}

protocol DVBaseMediaViewController: DVControllerSetup & DVButtonsAction {
    
    var viewModel: DVBaseMediaViewModel { get }
    
    init(viewModel: DVBaseMediaViewModel)
    
    
    func setupDetailsView(data value: Data)
    func showErrorAlert(with message: String)
    
}
