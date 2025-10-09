//
//  PhotoViewerController.swift
//  Povareshka
//
//  Created by user on 23.07.2025.
//

import UIKit

final class PhotoViewerController: BaseController {
    private let photos: [String]
    private let initialIndex: Int
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .horizontalFixedSize(),
            cellConfigs: [
                CollectionViewCellConfig(cellClass: PhotoViewerCell.self, identifier: PhotoViewerCell.id)
            ],
            delegate: self,
            dataSource: self,
            isScrollEnabled: true,
            minimumInteritemSpacing: 0,
            minimumLineSpacing: 0
        )
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    private lazy var closeButton = UIButton(image: AppImages.Icons.deleteX,
                                            backgroundColor: .black.withAlphaComponent(0.3),
                                            cornerRadius: Constants.cornerRadiusMedium,
                                            size: Constants.iconCellSizeMedium,
                                            target: self,
                                            action: #selector(close))
    
    init(photos: [String], initialIndex: Int = 0) {
        self.photos = photos
        self.initialIndex = initialIndex
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        
    }
    
    internal override func setupViews() {
        super.setupViews()
        view.backgroundColor = .white
        view.addSubview(collectionView)
        view.addSubview(closeButton)
        
        collectionView.scrollToItem(at: IndexPath(item: initialIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    internal override func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.paddingMedium),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingMedium),
        ])
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
}

extension PhotoViewerController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoViewerCell.id, for: indexPath) as? PhotoViewerCell else {
            return PhotoViewerCell()
        }
        cell.configure(with: photos[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}


