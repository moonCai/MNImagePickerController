//
//  ImageCollectionViewCell.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/10/12.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    lazy var displayImageView = UIImageView(image: UIImage(named: "cameraIcon"))
    lazy var playImageView = UIImageView(image: UIImage(named: "playIcon"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        contentView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        contentView.addSubview(displayImageView)
        contentView.addSubview(playImageView)
        
        displayImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        playImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        displayImageView.contentMode = .scaleAspectFill
        displayImageView.clipsToBounds = true
        playImageView.isHidden = true
        playImageView.isUserInteractionEnabled = true
    }
    
}


