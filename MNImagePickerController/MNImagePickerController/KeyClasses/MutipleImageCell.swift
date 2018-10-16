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
        imageView.backgroundColor = .yellow
        return imageView
    }()
    lazy var selectButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "unselected"), for: .normal)
        button.setImage(UIImage(named: "selected"), for: .selected)
        button.addTarget(self, action: #selector(selectButtonAction(sender:)), for: .touchUpInside)
        return button
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
        contentView.addSubview(selectButton)
        
        displayImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        selectButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(2)
            $0.trailing.equalToSuperview().offset(-2)
            $0.size.equalTo(CGSize(width: 25, height: 25))
        }
    }
    
    @objc func selectButtonAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
}
