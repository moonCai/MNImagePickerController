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
    
    // - 数据源
    var selectedImages: [UIImage] = [] {
        didSet {
            collectionView.reloadData()
            updateCollectionViewHeightWithImages(count: selectedImages.count)
        }
    }
    var isVideo: Bool = false
    var selectClsoure: ((Int)->())?
    
    lazy var desribeTextView: PlaceholderTextView = {
        let textView = PlaceholderTextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.placeLabel.font = UIFont.systemFont(ofSize: 15)
        textView.textColor = .darkGray
        textView.placeLabel.text = "这一刻的想法.."
        textView.delegate = self
        return textView
    }()
    lazy var flowLayout = UICollectionViewFlowLayout()
    lazy var collectionView: UICollectionView = {
        flowLayout.itemSize = CGSize(width: imageCellWH, height: imageCellWH)
        flowLayout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCellID)
        collectionView.dataSource = self
        collectionView.delegate = self
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
    
}

// MARK: - ConfigureUI
extension NewsDetailCell {
    
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
            $0.height.equalTo(imageCellWH + 5)
            $0.bottom.equalToSuperview().offset(-15).priority(999)
        }
    }
    
    func updateCollectionViewHeightWithImages(count: Int) {
        switch isVideo {
        case true:
            let collectionHeight = screenHeight * imageCellWH / screenWidth
            flowLayout.itemSize = CGSize(width: imageCellWH, height: collectionHeight)
            collectionView.snp.remakeConstraints {
                $0.leading.equalToSuperview().offset(20)
                $0.top.equalTo(desribeTextView.snp.bottom).offset(15)
                $0.trailing.equalToSuperview().offset(-20)
                $0.height.equalTo(collectionHeight)
                $0.bottom.equalToSuperview().offset(-15).priority(999)
            }
        case false:
            var rows: CGFloat = 0
            switch count {
            case  0 ..< 3:
                rows = 1
            case  3 ..< 6:
                rows = 2
            case  6 ... 9:
                rows = 3
            default:
                print(count)
            }
            collectionView.snp.remakeConstraints {
                $0.leading.equalToSuperview().offset(20)
                $0.top.equalTo(desribeTextView.snp.bottom).offset(15)
                $0.trailing.equalToSuperview().offset(-20)
                $0.height.equalTo((imageCellWH + 5) * rows)
                $0.bottom.equalToSuperview().offset(-15).priority(999)
            }
        }
    }
    
}

// MARK: - UICollectionViewDataSource
extension NewsDetailCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch isVideo {
        case true:
            return 1
        case false:
            return selectedImages.count < 9 ? selectedImages.count + 1 : 9
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCellID, for: indexPath) as! ImageCollectionViewCell
        switch isVideo {
        case true:
            cell.displayImageView.image = selectedImages.first
            cell.playImageView.isHidden = false
        case false:
            if selectedImages.count < 9, indexPath.item == selectedImages.count {
                cell.displayImageView.image = UIImage(named: "cameraIcon")
            } else {
                cell.displayImageView.image = selectedImages[indexPath.item]
            }
        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension NewsDetailCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectClsoure?(indexPath.item)
    }
}

// MARK: - UITextViewDelegate
extension NewsDetailCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView == desribeTextView else { return }
        desribeTextView.placeLabel.isHidden = textView.hasText
    }
}
