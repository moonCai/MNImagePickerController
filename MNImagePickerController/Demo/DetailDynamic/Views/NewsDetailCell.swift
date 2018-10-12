//
//  NewsDetailCell.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/10/12.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

let NewsDetailCellID = "NewsDetailCellID"
class NewsDetailCell: UITableViewCell {
    
    lazy var desribeTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.text = "这一刻的想法..."
        textView.textColor = .darkGray
        return textView
    }()
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .yellow
        return collectionView
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: NewsDetailCellID)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        contentView.addSubview(desribeTextView)
        contentView.addSubview(collectionView)
        
        desribeTextView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(70)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(desribeTextView.snp.bottom).offset(15)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(140)
            $0.bottom.equalToSuperview().offset(-15)
        }
    }

}
