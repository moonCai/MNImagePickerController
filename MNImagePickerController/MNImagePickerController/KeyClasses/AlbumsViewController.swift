//
//  AlbumsViewController.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/10/18.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit
import Photos

class AlbumsViewController: UIViewController {
    
    // - 数据源
    var albums: [DisplayAlbumsModel] = []
    
    lazy var albumsTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.register(AlbumsCell.self, forCellReuseIdentifier: AlbumsCellID)
        tableView.rowHeight = 60
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCustomPhotoAlbum()
    }

}

// MARK: - ConfigureUI
extension AlbumsViewController {
    
    func configureUI() {
        title = "照片"
        
        view.addSubview(albumsTableView)
        albumsTableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.topLayoutGuide.snp.bottom)
            $0.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
    }
    
}

extension AlbumsViewController {
    
    // - 获取相册 / 相册数组
    func configureCustomPhotoAlbum() {
        // - 获取相册 / 相册数组
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        print(smartAlbums.count)
        
        smartAlbums.enumerateObjects { (assetCollection, index, _) in
            // - 获取所有可视相册
            if assetCollection.isKind(of: PHAssetCollection.self), assetCollection.assetCollectionSubtype != .smartAlbumAllHidden {
                
              let assets = PHAsset.fetchAssets(in: assetCollection, options: nil)
                let albumsModel = DisplayAlbumsModel()
                albumsModel.imagesCount = assets.count
                albumsModel.albumsName = assetCollection.localizedTitle ?? ""
                if assets.count > 0 {
                    PHImageManager.default().requestImage(for: assets.lastObject!, targetSize: CGSize(width: 60 * UIScreen.main.scale, height: 60 * UIScreen.main.scale), contentMode: .aspectFill, options: nil, resultHandler: { (lastImage, _) in
                        albumsModel.coverImage = lastImage!
                    })
                }
                self.albums.append(albumsModel)
            }
        }
        albumsTableView.reloadData()
    }
    
}

extension AlbumsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumsCellID, for: indexPath) as! AlbumsCell
        cell.albumModel = albums[indexPath.row]
        return cell
    }
}
