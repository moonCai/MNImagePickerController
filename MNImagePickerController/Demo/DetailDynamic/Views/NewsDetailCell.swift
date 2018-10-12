//
//  NewsDetailCell.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/10/12.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

let NewsDetailCellID = "NewsDetailCellID"
let ImageCollectionViewCellID = "ImageCollectionViewCellID"
let imageCellWH: CGFloat = (screenWidth - 50) / 3
class NewsDetailCell: UITableViewCell {
    
    lazy var desribeTextView: PlaceholderTextView = {
        let textView = PlaceholderTextView()
        textView.font = UIFont.systemFont(ofSize: 15)
         textView.placeLabel.font = UIFont.systemFont(ofSize: 15)
        textView.textColor = .darkGray
        textView.placeLabel.text = "这一刻的想法.."
        textView.delegate = self
        return textView
    }()
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: imageCellWH, height: imageCellWH)
        flowLayout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCellID)
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
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
        selectionStyle = .none
        
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
            $0.height.equalTo(imageCellWH)
            $0.bottom.equalToSuperview().offset(-15)
        }
    }

}

extension NewsDetailCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCellID, for: indexPath)
        return cell
    }
}

extension NewsDetailCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView == desribeTextView else { return }
        desribeTextView.placeLabel.isHidden = textView.hasText
    }
}
