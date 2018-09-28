//
//  NewsTableHeaderView.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/8/23.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

class NewsTableHeaderView: UIView {
    
    private lazy var backImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "cup")
        imageView.clipsToBounds = true
        return imageView
    }()
    private lazy var boarderView: UIView = {
        let view = UIView()
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.2
        view.layer.shadowColor = UIColor.black.cgColor
        return view
    }()
     lazy var portraitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "rect_portrait"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        button.clipsToBounds = true
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        addSubview(backImageView)
        addSubview(boarderView)
        boarderView.addSubview(portraitButton)
        
        backImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(3 * screenWidth / 4)
        }
        boarderView.snp.makeConstraints {
            $0.bottom.equalTo(backImageView).offset(20)
            $0.trailing.equalToSuperview().offset(-10)
            $0.size.equalTo(CGSize(width: 80, height: 80))
        }
        portraitButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}
