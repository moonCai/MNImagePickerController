//
//  AlbumsCell.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/10/18.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit
import Photos

let AlbumsCellID = "AlbumsCellID"
class AlbumsCell: UITableViewCell {
    
    var albumModel = DisplayAlbumsModel() {
        didSet {
            setCellInfoWith(model: albumModel)
        }
    }
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "placeHolder")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    lazy var titleLable: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    lazy var rightArrowButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "rightArrow"), for: .normal)
        return button
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - ConfigureUI
extension AlbumsCell {
    
    func configureUI() {
        selectionStyle = .none
        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLable)
        contentView.addSubview(countLabel)
        contentView.addSubview(rightArrowButton)
        
        coverImageView.snp.makeConstraints{
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 60, height: 60))
        }
        titleLable.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(coverImageView.snp.trailing).offset(10)
        }
        countLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(titleLable.snp.trailing).offset(15)
        }
        rightArrowButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
    
    func setCellInfoWith(model: DisplayAlbumsModel) {
        coverImageView.image = model.coverImage
        titleLable.text = model.albumsName
        countLabel.text = "(\(model.albumAssets.count))"
        
        if let lastAsset = model.albumAssets.last {
            PHImageManager.default().requestImage(for: lastAsset, targetSize: CGSize(width: 60 * UIScreen.main.scale, height: 60 * UIScreen.main.scale), contentMode: .aspectFill, options: nil, resultHandler: { [unowned self](lastImage, _) in
                self.coverImageView.image = lastImage!
            })
        }
    }
    
}

