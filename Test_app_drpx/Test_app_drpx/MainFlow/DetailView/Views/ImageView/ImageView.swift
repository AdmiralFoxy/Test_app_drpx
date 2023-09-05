//
//  ImageView.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 04/09/2023.
//

import UIKit
import Combine

final class ImageView: UIViewController {
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.addTarget(
            self,
            action: #selector(closeButtonPressed),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton(type: .infoLight)
        button.addTarget(
            self,
            action: #selector(infoButtonPressed),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: ImageViewModel
    
    init(viewModel: ImageViewModel) {
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.frame = view.bounds
    }
    
}

private extension ImageView {
    
    func setupBindings() {
        viewModel.setImageAction
            .call(self, type(of: self).setupImage)
            .store(in: &cancellables)
        
        viewModel.viewState
            .call(self, type(of: self).handleViewState)
            .store(in: &cancellables)
    }
    
    func setupImage(_ image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = image
        }
    }
    
    func handleViewState(_ state: ViewState) {
        switch state {
        case .loading:
            activityIndicator.startAnimating()
            imageView.isHidden = true
            
        case .idle:
            activityIndicator.stopAnimating()
            imageView.isHidden = true
            
        case .onSuccess:
            activityIndicator.stopAnimating()
            imageView.isHidden = false
            
        case .onFailure(let string):
            activityIndicator.stopAnimating()
            imageView.isHidden = true
            showErrorAlert(with: string)
        }
    }
    
    func showErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc
    func closeButtonPressed() {
        viewModel.viewButtonAction.send(.close)
    }
    
    @objc
    func infoButtonPressed() {
        viewModel.viewButtonAction.send(.info(path: viewModel.filePath))
    }
    
}

private extension ImageView {
    
    func setupView() {
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.width.height.equalTo(40.0)
            $0.leading.equalToSuperview().inset(24.0)
            $0.top.equalToSuperview().inset(54.0)
        }
        closeButton.backgroundColor = .red
        
        view.addSubview(infoButton)
        infoButton.snp.makeConstraints {
            $0.center.equalTo(closeButton.snp.center)
            $0.trailing.equalToSuperview().inset(24.0)
        }
    }
    
}
