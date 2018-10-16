//
//  MutiplePhotoAlbumController.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/10/16.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

let mutipleImageWH: CGFloat = (screenWidth - 3) / 4
let MutipleImageCellID = "MutipleImageCellID"
class MutiplePhotoAlbumController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: mutipleImageWH, height: mutipleImageWH)
        flowLayout.minimumLineSpacing = 1
        flowLayout.minimumInteritemSpacing = 1
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .white
        collectionView.register(MutipleImageCell.self, forCellWithReuseIdentifier: MutipleImageCellID)
        collectionView.dataSource = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
}

// MARK: - ConfigureUI
extension MutiplePhotoAlbumController {
    
    func configureUI() {
        title = "相机胶卷"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(backBarItemAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(dismissBarItemAction))
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}

// MARK: - UICollectionViewDataSource
extension MutiplePhotoAlbumController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MutipleImageCellID, for: indexPath)
        return cell
    }
}

// MARK: - Event Response
extension MutiplePhotoAlbumController {
    
    @objc func backBarItemAction() {
        print("返回相册分组")
    }
    
    @objc func dismissBarItemAction() {
        dismiss(animated: true, completion: nil)
    }
    
}
