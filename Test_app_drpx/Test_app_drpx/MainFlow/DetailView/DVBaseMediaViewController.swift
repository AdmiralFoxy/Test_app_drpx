//
//  DVBaseMediaViewController.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import Foundation

protocol DVControllerSetup {
    
    // MARK: DVControllerSetup properties
    
    func setupView()
    func setupBindings()
    func handleViewState(_ state: ViewState)
    
}

protocol DVButtonsAction {
    
    // MARK: DVButtonsAction properties
    
    func closeButtonPressed()
    func infoButtonPressed()
    
}

protocol DVBaseMediaViewController: DVControllerSetup & DVButtonsAction {
    
    // MARK: DVBaseMediaViewController properties
    
    var viewModel: DVBaseMediaViewModel { get }
    
    // MARK: initialize
    
    init(viewModel: DVBaseMediaViewModel)
    
    func setupDetailsView(data value: Data)
    func showErrorAlert(with message: String)
    
}
