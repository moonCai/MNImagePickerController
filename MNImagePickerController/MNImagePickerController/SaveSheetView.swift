//
//  SaveSheetView.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/8/28.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

enum SheetButtonType: Int {
    case save = 0
    case cancel = 1
    case camera = 2
}

class SaveSheetView: UIView {
    
    var sheetClosure: ((SheetButtonType)->())?
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 55))
        button.setTitle("保存图片", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tag = 0
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(sheetButtonsAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 55))
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tag = 1
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
    
    private func configureUI() {
        backgroundColor = .groupTableViewBackground
        addSubview(saveButton)
        addSubview(cancelButton)
    }
    
    @objc func sheetButtonsAction(sender: UIButton) {
        switch SheetButtonType(rawValue: sender.tag)! {
        case .save:
            sheetClosure?(.save)
        case .cancel:
            sheetClosure?(.cancel)
        default:
            print(sender.tag)
        }
    }
    
}
