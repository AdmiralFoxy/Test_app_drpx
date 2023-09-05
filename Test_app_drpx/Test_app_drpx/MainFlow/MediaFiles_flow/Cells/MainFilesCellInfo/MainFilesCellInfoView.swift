//
//  MainFilesCellInfoView.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Foundation
import UIKit
import Combine

final class MainFilesCellInfoView: UICollectionViewCell {
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 9)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    // MARK: - Initialization
    var viewModel: MainFilesCellInfoViewModel {
        didSet {
            configureViews()
            setupSubviews()
        }
    }
    private var cancellables = Set<AnyCancellable>()
    
    init(frame: CGRect, viewModel: MainFilesCellInfoViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints {
            $0.bottom.equalTo(titleLabel.snp.top).inset(8.0)
            $0.leading.trailing.top.equalToSuperview()
        }
    }
    
    // MARK: - Bind ViewModel
    
    private func configureViews() {
        UIView.animate(withDuration: 0.35) { [weak self] in
            guard let self = self else { return }
            
            self.titleLabel.text = viewModel.title
            self.thumbnailImageView.image = viewModel.image
        }
    }
    
}
