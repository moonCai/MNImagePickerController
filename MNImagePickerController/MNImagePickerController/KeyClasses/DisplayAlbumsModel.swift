//
//  DisplayAlbumsModel.swift
//  MNImagePickerController
//
//  Created by moonCai on 2018/10/19.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit
import Photos

class DisplayAlbumsModel: NSObject {
    // 封面
    var coverImage = UIImage(named: "placeHolder")
    // 相册名
    var albumsName: String = ""
    // 相册内所有图片资产
    var albumAssets: [PHAsset] = []
}
