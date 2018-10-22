//
//  MutiplePhotoAlbumController.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/10/16.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit
import Photos

let mutipleImageWH: CGFloat = (screenWidth - 25) / 4
let MutipleImageCellID = "MutipleImageCellID"
class MutiplePhotoAlbumController: UIViewController {
    
    // - 数据源
    lazy var rollImageModels: [DisplayImageModel] = []
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        flowLayout.itemSize = CGSize(width: mutipleImageWH, height: mutipleImageWH)
        flowLayout.minimumLineSpacing = 5
        flowLayout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .white
        collectionView.register(MutipleImageCell.self, forCellWithReuseIdentifier: MutipleImageCellID)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCustomPhotoAlbum()
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
    
    // - 配置胶卷相册视图
    func configureCustomPhotoAlbum() {
        // - 获取相册 / 相册数组
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        
        // - 获取相机胶圈这个相册
        smartAlbums.enumerateObjects { (assetCollection, index, _) in
            if assetCollection.assetCollectionSubtype == .smartAlbumUserLibrary {
                let assets = PHAsset.fetchAssets(in: assetCollection, options: PHFetchOptions())
                assets.enumerateObjects({ (asset, index, _) in
                    self.rollImageModels.append(DisplayImageModel(asset: asset))
                })
                // - 刷新页面
                self.collectionView.reloadData()
                // - 只有目标cell是可视的,直接调用滚动到指定cell的方法才有效. 否则需要先更新视图布局
                self.collectionView.layoutIfNeeded()
                self.collectionView.scrollToItem(at: IndexPath(row: self.rollImageModels.count - 1, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
}

// MARK: - UICollectionViewDataSource
extension MutiplePhotoAlbumController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rollImageModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MutipleImageCellID, for: indexPath) as! MutipleImageCell
        cell.imageModel = rollImageModels[indexPath.row]
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MutiplePhotoAlbumController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        let controller = MutipleImagesBrowserController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

// MARK: - Event Response
extension MutiplePhotoAlbumController {
    
    // - 点击返回
    @objc func backBarItemAction() {
        navigationController?.popViewController(animated: true)
    }
    
    // - 点击取消
    @objc func dismissBarItemAction() {
        dismiss(animated: true, completion: nil)
    }
    
}
