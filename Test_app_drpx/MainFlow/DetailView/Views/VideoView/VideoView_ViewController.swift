//
//  VideoView_ViewController.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import UIKit
import Combine
import AVKit

final class VideoView_ViewController: UIViewController, DVBaseMediaViewController {
    
    // MARK: properties
    
    var viewModel: DVBaseMediaViewModel
    
    private let playerViewController = AVPlayerViewController()
    
    private var player: AVPlayer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - subview
    
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
    
    // MARK: initialize
    
    init(viewModel: DVBaseMediaViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlayerView()
        setupBindings()
        setupView()
    }
    
}

// MARK: - setup view, subviews, bindings

extension VideoView_ViewController {
    
    func setupView() {
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
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
    
    func setupDetailsView(data value: Data) {
        let temporaryDirectoryURL = URL(
            fileURLWithPath: NSTemporaryDirectory(),
            isDirectory: true
        )
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
        
        do {
            try value.write(to: temporaryFileURL)
            
            let asset = AVAsset(url: temporaryFileURL)
            let playerItem = AVPlayerItem(asset: asset)
            player = AVPlayer(playerItem: playerItem)
            
            playerViewController.player = player
            
            viewModel.viewState.send(.onSuccess)
        } catch {
            showErrorAlert(
                with: "Unable to write data to file: \(error.localizedDescription)"
            )
        }
    }
    
    func setupPlayerView() {
        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        playerViewController.didMove(toParent: self)
    }
    
    func setupBindings() {
        viewModel.viewState
            .receive(on: RunLoop.main)
            .call(self, type(of: self).handleViewState)
            .store(in: &cancellables)
        
        viewModel.setDataAction
            .receive(on: RunLoop.main)
            .call(self, type(of: self).setupDetailsView)
            .store(in: &cancellables)
    }
    
}

// MARK: - helper methods

extension VideoView_ViewController {
    
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
        guard let info = viewModel.fileInfo.value else { return }
        
        viewModel.viewButtonAction.send(.info(file: info))
    }
    
    func handleViewState(_ viewState: ViewState) {
        switch viewState {
        case .loading:
            activityIndicator.startAnimating()
            playerViewController.view.isHidden = true
            
        case .idle:
            activityIndicator.stopAnimating()
            playerViewController.view.isHidden = true
            
        case .onSuccess:
            activityIndicator.stopAnimating()
            playerViewController.view.isHidden = false
            player?.play()
            
        case .onFailure(let string):
            playerViewController.view.isHidden = true
            activityIndicator.stopAnimating()
            showErrorAlert(with: string)
        }
    }
    
}
