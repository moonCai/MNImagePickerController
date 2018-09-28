//
//  MediaChooseSheetView.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/9/28.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

enum HandleMediaType: Int {
    case shoot = 1
    case album = 2
    case cancel = 3
}

class MediaChooseSheetView: UIView {
    
    var mediaTypeClosure: ((HandleMediaType)->())?
    
    private lazy var shootButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 55))
        button.setTitle("拍摄", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tag = 1
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(sheetButtonsAction(sender:)), for: .touchUpInside)
        return button
    }()
    private lazy var partline = UIView(frame: CGRect(x: 0, y: 54, width: screenWidth, height: 1))
    private lazy var albumButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 55, width: screenWidth, height: 55))
        button.setTitle("从相册选择", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tag = 2
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(sheetButtonsAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 120, width: screenWidth, height: 55))
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tag = 3
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(sheetButtonsAction(sender:)), for: .touchUpInside)
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
        partline.backgroundColor = .groupTableViewBackground
        backgroundColor = .groupTableViewBackground
        
        addSubview(shootButton)
        addSubview(partline)
        addSubview(albumButton)
        addSubview(cancelButton)
    }
    
    @objc func sheetButtonsAction(sender: UIButton) {
        let type = HandleMediaType(rawValue: sender.tag)!
        mediaTypeClosure?(type)
    }
    
}
