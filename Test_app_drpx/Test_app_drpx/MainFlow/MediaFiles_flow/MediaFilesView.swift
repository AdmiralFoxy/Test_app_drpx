//
//  MediaFilesView.swift
//  Test_app_drpx
//
//  Created by Stanislav Avramenko on 02/09/2023.
//

import Foundation
import UIKit
import Combine

final class MediaFilesView: UIViewController {
    
    private let viewModel: MediaFilesViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var placeholderView: UIView = {
        let view = UIView()
        let label = UILabel()
        label.text = "No media files available."
        label.textColor = .gray
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(
            width: view.frame.width / 1.8,
            height: view.frame.width / 1.8
        )
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.borderColor = UIColor.red.cgColor
        collectionView.layer.borderWidth = 1.0
        collectionView.register(
            MainFilesCellInfoView.self,
            forCellWithReuseIdentifier: "MainFilesCellInfoView"
        )
        return collectionView
    }()
    
    init(viewModel: MediaFilesViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        setupUIView()
    }
    
}

// MARK: helper methods

private extension MediaFilesView {
    
    func setupBindings() {
        viewModel.mediaFiles
            .debounce(for: 0.35, scheduler: RunLoop.main)
            .map { (mediaFiles) -> [MediaFile] in
                var uniqueFiles: [MediaFile] = []
                for file in mediaFiles {
                    if !uniqueFiles.contains(where: {
                        $0.name == file.name && $0.path == file.path
                    }) {
                        uniqueFiles.append(file)
                    }
                }
                return uniqueFiles
            }
            .sink(receiveValue: mediaFilesUpdateHandl)
            .store(in: &cancellables)
        
        viewModel.mediaFiles
            .sink { [weak self] files in
                self?.placeholderView.isHidden = !files.isEmpty
            }
            .store(in: &cancellables)
    }
    
    func mediaFilesUpdateHandl(_ media: [MediaFile]) {
        placeholderView.isHidden = !media.isEmpty
        collectionView.reloadData()
    }
    
    func setupUIView() {
        setupCollectionView()
        setupPlaceholder()
    }
    
    // MARK: subviews
    
    func setupPlaceholder() {
        view.addSubview(placeholderView)
        placeholderView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(44.0)
            $0.leading.trailing.equalToSuperview().inset(16.0)
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension MediaFilesView: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel.mediaFiles.value.count
    }
    
    
}

// MARK: - UICollectionViewDelegate

extension MediaFilesView: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MainFilesCellInfoView",
            for: indexPath
        ) as! MainFilesCellInfoView
        let mediaFile = viewModel.mediaFiles.value[indexPath.item]
        
        let model = MainFilesCellInfoModel(
            title: mediaFile.name,
            path: mediaFile.path
        )
        cell.viewModel = MainFilesCellInfoViewModel(model: model)
        
        if indexPath.item == viewModel.mediaFiles.value.count - 1 {
            viewModel.fetchMoreFilesAction.send(())
        }
        
        return cell
    }
    
}
