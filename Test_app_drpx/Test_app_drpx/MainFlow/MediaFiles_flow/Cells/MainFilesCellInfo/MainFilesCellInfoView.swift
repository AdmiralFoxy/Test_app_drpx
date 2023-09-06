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
    
    private lazy var backView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        button.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    
    weak var viewModel: MainFilesCellInfoViewModel! {
        didSet {
            configureViews()
            setupSubviews()
            setupBindings()
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel.cancelImgLoadingAction.send(())
        
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        thumbnailImageView.image = nil
        titleLabel.text = nil
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        viewModel.setImgPreviewAction
            .receive(on: RunLoop.main)
            .call(thumbnailImageView, UIImageView.setupImage)
            .store(in: &cancellables)
    }
    
    private func setupGestureRecognizers(for views: [UIView]) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        views.forEach {
            $0.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func handleTap() {
        let filePath = FilePath(path: viewModel.filePath)
        
        viewModel.cellTapAction.send(filePath)
    }
    
    @objc private func didTapMenuButton() {
        let menu = UIMenu(title: "", children: [
            UIAction(title: "Move", image: UIImage(systemName: "arrowshape.turn.up.right")) { [weak self] _ in
                self?.viewModel.moveFileAction.send()
            },
            UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.viewModel.deleteFileAction.send()
            }
        ])
        menuButton.menu = menu
        menuButton.showsMenuAsPrimaryAction = true
    }
    
    private func setupSubviews() {
        addSubview(backView)
        backView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addSubview(titleLabel)
        addSubview(thumbnailImageView)
        addSubview(menuButton)
        
        titleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(8.0)
            $0.leading.trailing.equalToSuperview().inset(16.0)
        }
        
        thumbnailImageView.snp.makeConstraints {
            $0.bottom.equalTo(titleLabel.snp.top).inset(8.0)
        }
        
        menuButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8.0)
            $0.trailing.equalToSuperview().inset(8.0)
            $0.width.height.equalTo(30.0)
        }
        
        setupGestureRecognizers(for: [titleLabel, thumbnailImageView, backView])
    }
    
    // MARK: - Configure View
    
    private func configureViews() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.titleLabel.text = viewModel.title
        }
    }
    
}

extension UIImageView {
    
    func setupImage(_ image: UIImage?) {
        self.image = image
    }
    
}
