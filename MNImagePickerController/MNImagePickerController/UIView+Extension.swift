//
//  UIView+Extension.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/8/24.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

extension UIView {
    
    /// 对当前控件进行截图
    func toRetinaImageInRect() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        self.layer.render(in: context!)
        let shotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return shotImage!
    }
}
