//
//  DVViewController.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 03/09/2023.
//

import Foundation
import UIKit
import Combine

final class DVViewController: UIViewController {
    
    private let viewModel: DVViewModel
    
    private var imageView: UIImageView!
    private var pdfView: WKWebView!
    private var videoView: AVPlayerViewController!
    private var loadingIndicator: UIActivityIndicatorView!
    
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: DVViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func setupBindings() {
        viewModel.viewState
            .call(self, type(of: self).handleViewState)
            .store(in: &cancellables)
        
        viewModel.isShowDetailsView
            .compactMap { $0 }
            .call(self, type(of: self).isShowDetailsHandle)
            .store(in: &cancellables)
    }
}

private extension DVViewController {
    
    func isShowDetailsHandle(_ type: FileType) {
        switch type {
        case .image(let data):
            displayImage(data: data)
            
        case .pdf(let data):
            displayPDF(data: data)
            
        case .video(let data):
            displayVideo(data: data)
        }
    }
    
    func handleViewState(_ viewState: ViewState) {
        switch viewState {
        case .loading:
            <#code#>
            
        case .onSuccess, .idle:
            <#code#>
            
        case .onFailure(let string):
            <#code#>
        }
    }
    
    func displayImage(data: Data) {
        imageView = UIImageView(frame: self.view.frame)
        if let image = UIImage(data: data) {
            imageView.image = image
        }
        self.view.addSubview(imageView)
    }
    
    // Отображение PDF
    func displayPDF(data: Data) {
        pdfView = WKWebView(frame: self.view.frame)
        pdfView.load(data, mimeType: "application/pdf", characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: ""))
        self.view.addSubview(pdfView)
    }
    
    // Отображение видео
    func displayVideo(data: Data) {
        let tempPath = NSTemporaryDirectory() + "tempVideo.mp4"
        let tempURL = URL(fileURLWithPath: tempPath)
        do {
            try data.write(to: tempURL)
            let player = AVPlayer(url: tempURL)
            videoView = AVPlayerViewController()
            videoView.player = player
            self.present(videoView, animated: true) {
                self.videoView.player?.play()
            }
        } catch {
            print("Error saving video: \(error)")
        }
    }
    
}
