//
//  PlaceholderTextView.swift
//  MicGroup
//
//  Created by 瓷月亮 on 2018/5/14.
//  Copyright © 2018年 Johnson. All rights reserved.
//

import UIKit
import SnapKit

class PlaceholderTextView: UITextView {

    lazy var placeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        return label
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        addSubview(placeLabel)
        placeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(5)
        }
    }
    
}
