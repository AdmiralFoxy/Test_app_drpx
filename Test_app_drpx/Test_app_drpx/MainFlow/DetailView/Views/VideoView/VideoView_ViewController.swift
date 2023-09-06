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
    
    private var cancellables = Set<AnyCancellable>()
    
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
    
    var viewModel: DVBaseMediaViewModel
    
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
    
    
    
    func handleViewState(_ viewState: ViewState) {
        switch viewState {
        case .loading:
            activityIndicator.startAnimating()
//            pdfView.isHidden = true
//
        case .idle:
            activityIndicator.stopAnimating()
//            pdfView.isHidden = false
            
        case .onSuccess:
            activityIndicator.stopAnimating()
//            pdfView.isHidden = false
            
        case .onFailure(let string):
            activityIndicator.stopAnimating()
//            pdfView.isHidden = true
            showErrorAlert(with: string)
        }
    }
    
    func setupView() {
//        view.addSubview(pdfView)
//        pdfView.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
        
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
        
        view.addSubview(infoButton)
        infoButton.snp.makeConstraints {
            $0.center.equalTo(closeButton.snp.center)
            $0.trailing.equalToSuperview().inset(24.0)
        }
        
        closeButton.backgroundColor = .red
        infoButton.backgroundColor = .red
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
            let player = AVPlayer(playerItem: playerItem)
            let playerViewController = AVPlayerViewController()
            
            playerViewController.player = player
            
            present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
            
            viewModel.viewState.send(.onSuccess)
        } catch {
            showErrorAlert(
                with: "Unable to write data to file: \(error.localizedDescription)"
            )
        }
    }
    
}
