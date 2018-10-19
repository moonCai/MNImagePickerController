//
//  DisplayAlbumsModel.swift
//  MNImagePickerController
//
//  Created by moonCai on 2018/10/19.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

class DisplayAlbumsModel: NSObject {
    // 封面
    var coverImage = UIImage(named: "placeHolder")
    // 相册名
    var albumsName: String = ""
    // 图片张数
    var imagesCount: Int = 0
}
