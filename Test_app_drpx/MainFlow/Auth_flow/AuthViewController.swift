//
//  AuthViewController.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 01/09/2023.
//

import Combine
import UIKit
import SnapKit
import SwiftyDropbox

final class AuthViewController: UIViewController {
    
    // MARK: - properties
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.addTarget(
            self,
            action: #selector(loginButtonPressed),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: AuthViewModel
    private let navigationNode: NavigationNode
    
    // MARK: - initialize
    
    init(viewModel: AuthViewModel, navigationNode: NavigationNode) {
        self.viewModel = viewModel
        self.navigationNode = navigationNode
        
        super.init(nibName: nil, bundle: nil)
        
        setupUIView()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: setup view

private extension AuthViewController {
    
    // MARK: - subviews
    
    func setupUIView() {
        setupBack()
        setupLoadingIndicator()
        setupLoginUI()
        
    }
    
    func setupBack() {
        view.backgroundColor = .white
    }
    
    func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints {
            $0.top.equalToSuperview().inset(56.0)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    func setupLoginUI() {
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24.0)
        }
    }
    
}

// MARK: - actions

private extension AuthViewController {
    
    @objc
    func loginButtonPressed() {
        viewModel.loginAction.send(self)
    }
    
}

// MARK: - helper methods

private extension AuthViewController {
    
    func showAlert(with title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - loading delegate

extension AuthViewController: LoadingStatusDelegate {
    
    func showLoading() {
        loadingIndicator.startAnimating()
    }
    
    func dismissLoading() {
        loadingIndicator.stopAnimating()
    }
    
}
