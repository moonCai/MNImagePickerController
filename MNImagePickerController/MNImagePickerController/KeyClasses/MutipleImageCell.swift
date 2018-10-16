//
//  MutipleImageCell.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/10/16.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

class MutipleImageCell: UICollectionViewCell {
    
    lazy var displayImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .green
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        contentView.addSubview(displayImageView)
        
        displayImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}
