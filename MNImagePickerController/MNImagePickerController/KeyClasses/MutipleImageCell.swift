//
//  MutipleImageCell.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/10/16.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit
import Photos

class MutipleImageCell: UICollectionViewCell {
    
    // 数据源
    var imageModel = DisplayImageModel() {
        didSet {
            setCellInfoWith(model: imageModel)
        }
    }
    
    lazy var displayImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    lazy var selectButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "unselected"), for: .normal)
        button.setImage(UIImage(named: "selected"), for: .selected)
        button.addTarget(self, action: #selector(selectButtonAction(sender:)), for: .touchUpInside)
        return button
    }()
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - ConfigureUI
extension MutipleImageCell {
    
    func configureUI() {
        contentView.addSubview(displayImageView)
        contentView.addSubview(selectButton)
        contentView.addSubview(timeLabel)
        
        displayImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        selectButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(2)
            $0.trailing.equalToSuperview().offset(-2)
            $0.size.equalTo(CGSize(width: 25, height: 25))
        }
        timeLabel.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().offset(-5)
        }
    }
    
    func setCellInfoWith(model: DisplayImageModel) {
        timeLabel.isHidden = model.asset.mediaType == .image
        selectButton.isSelected = imageModel.isSelected
        // - 显示视频时长
        if model.asset.mediaType == .video {
            let formatter = DateComponentsFormatter()
            if model.asset.duration < 3600 {
                 formatter.allowedUnits = [.minute, .second]
            } else {
                 formatter.allowedUnits = [.hour, .minute, .second]
            }
            formatter.zeroFormattingBehavior = .pad
            timeLabel.text = formatter.string(from: round(model.asset.duration))
        }
        // - 设置图片 / 视频封面
        let options = PHImageRequestOptions()
        options.version = .unadjusted
        PHImageManager.default().requestImage(for: model.asset, targetSize: CGSize(width: mutipleImageWH, height: mutipleImageWH), contentMode: .aspectFill, options: options) { (image, info) in
            if let coverImage = image {
                self.displayImageView.image = coverImage
                self.imageModel.image = coverImage
            } else {
                self.displayImageView.image = UIImage.createImageByColor(color: UIColor(white: 0.95, alpha: 1.0))
            }
        }
    }
    
}

// MARK: - Event Response
extension MutipleImageCell {
    
    @objc func selectButtonAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        imageModel.isSelected = sender.isSelected
    }
    
}
