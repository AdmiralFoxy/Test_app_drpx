//
//  FileInfoViewController.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 06/09/2023.
//

import UIKit

final class FileInfoViewController: UIViewController {
    
    // MARK: - subviews
    
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
    
    private lazy var detailsLabel: UILabel = {
        let detailsLabel = UILabel()
        
        detailsLabel.numberOfLines = 0
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.textColor = .white
        detailsLabel.text = """
        Name: \(viewModel.fileDetail.name)
        Path: \(viewModel.fileDetail.path)
        Client Modified: \(String(describing: viewModel.fileDetail.clientModified))
        Server Modified: \(String(describing: viewModel.fileDetail.serverModified))
        Content Hash: \(String(describing: viewModel.fileDetail.contentHash))
        ID: \(String(describing: viewModel.fileDetail.id))
        Is Downloadable: \(viewModel.fileDetail.isDownloadable ?? false ? "Yes" : "No")
        Size: \(String(describing: viewModel.fileDetail.size)) bytes
        """
        
        return detailsLabel
    }()
    
    // MARK: properties
    
    var viewModel: FileInfoViewModel!
    
    // MARK: initialize
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
}

private extension FileInfoViewController {
    
    // MARK: setup view
    
    func setupView() {
        view.backgroundColor = .black
        
        view.addSubview(detailsLabel)
        detailsLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(26.0)
            $0.bottom.equalToSuperview().inset(26.0)
            $0.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.width.height.equalTo(40.0)
            $0.leading.equalToSuperview().inset(24.0)
            $0.top.equalToSuperview().inset(54.0)
        }
    }
    
    // MARK: action
    
    @objc
    func closeButtonPressed() {
        viewModel.closeButtonAction.send(())
    }
    
}
