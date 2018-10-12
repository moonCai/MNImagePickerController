//
//  ImageCollectionViewCell.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/10/12.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView = UIImageView(image: UIImage(named: "cameraIcon"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


