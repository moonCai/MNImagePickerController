//
//  DisplayImageModel.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/10/17.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit
import Photos

class DisplayImageModel: NSObject {
    // 是否选中
    var isSelected: Bool = false
    // 图片 / 视频封面
    var image = UIImage()
    // 图片 / 视频资产
    var asset = PHAsset()
    
    convenience init(asset: PHAsset) {
        self.init()
        self.asset = asset
    }
}
