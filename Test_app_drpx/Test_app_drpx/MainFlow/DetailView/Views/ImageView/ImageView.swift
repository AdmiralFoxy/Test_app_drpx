//
//  ImageView.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 04/09/2023.
//

import UIKit
import Combine

final class ImageView: UIViewController {
    
    var viewModel: DVBaseMediaViewModel
    
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
    
    init(viewModel: DVBaseMediaViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        setupView()
    }
    
}

extension ImageView: DVBaseMediaViewController {
    
    func setupDetailsView(data value: Data) {
        guard let image = UIImage(data: value) else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            self.imageView.image = image
            self.viewModel.viewState.send(.onSuccess)
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
    
    func setupBindings() {
        viewModel.setDataAction
            .call(self, type(of: self).setupDetailsView)
            .store(in: &cancellables)
        
        viewModel.viewState
            .call(self, type(of: self).handleViewState)
            .store(in: &cancellables)
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
        guard let info = viewModel.fileInfo else { return }
        
        viewModel.viewButtonAction.send(.info(file: info))
    }
    
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
        closeButton.backgroundColor = .gray
        
        view.addSubview(infoButton)
        infoButton.snp.makeConstraints {
            $0.width.height.equalTo(40.0)
            $0.top.equalToSuperview().inset(54.0)
            $0.trailing.equalToSuperview().inset(24.0)
        }
        infoButton.backgroundColor = .lightGray
    }
    
}
