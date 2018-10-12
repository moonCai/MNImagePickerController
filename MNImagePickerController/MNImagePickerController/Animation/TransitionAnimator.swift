//
//  TransitionAnimator.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/10/11.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

enum MNAnimatorType {
    case modal
    case dismiss
}

class TransitionAnimator: NSObject {
    // 转场类型
    var type: MNAnimatorType = .modal
    // 缩略图
    lazy var portraitImage = UIImage()
    // 单图被点击时在屏幕上的位置
    var portraitCurrentRect = CGRect()
    
    convenience init(type: MNAnimatorType) {
        self.init()
        self.type = type
    }
}

extension TransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let containerView = transitionContext.containerView
        transitionContext.containerView.addSubview(toView)
        
        switch type {
        case .modal:
            let toController = transitionContext.viewController(forKey: .to) as! SimpleImageBrowseViewController
            
            self.portraitImage = toController.portraitImage
            self.portraitCurrentRect = toController.portraitCurrentRect
            
            let thumbImageView = UIImageView(image: portraitImage)
            thumbImageView.contentMode = .scaleAspectFill
            thumbImageView.clipsToBounds = true
            
            thumbImageView.frame = self.portraitCurrentRect
            containerView.addSubview(thumbImageView)
            
            let zoomScale = screenWidth / portraitCurrentRect.width
            
            var tran = CATransform3DIdentity
            let translateX = screenWidth / 2 - portraitCurrentRect.midX
            let translateY = screenHeight / 2 - portraitCurrentRect.midY
            tran = CATransform3DTranslate(tran, translateX, translateY, 50)
            tran.m34 = -1 / 1000.0
            tran = CATransform3DScale(tran, zoomScale, zoomScale, 1)
            
            toView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            UIView.animate(withDuration:transitionDuration(using: nil) * 0.5, animations: {
                thumbImageView.layer.transform = tran
                fromView.alpha = 0
            }, completion: { (_) in
                fromView.removeFromSuperview()
                UIView.animate(withDuration: self.transitionDuration(using: nil) * 0.5, animations: {
                    toController.opaqueSubviews()
                }, completion: { (_) in
                    thumbImageView.removeFromSuperview()
                    transitionContext.completeTransition(true)
                })
            })
        case .dismiss:
            
            let fromController = transitionContext.viewController(forKey: .from) as! SimpleImageBrowseViewController
            
            let imageView = fromController.browseImageView
            
            let largeImageView = UIImageView(image: imageView.image)
            largeImageView.clipsToBounds = true
            largeImageView.contentMode = .scaleAspectFill
            largeImageView.frame = fromController.browseScrollView.convert(imageView.frame, to: fromView)
            containerView.addSubview(largeImageView)
            
            let toImageView = fromController.animatedFromView
            let largeImageViewFrame = toImageView.convert(toImageView.bounds, to: containerView)
            var transform = CATransform3DIdentity
            transform.m34 = -1 / 1000.0
            largeImageView.layer.transform = transform
            
            fromController.browseImageView.isHidden = true
            toView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            
            UIView.animate(withDuration: self.transitionDuration(using: nil) * 0.5 , animations: {
                toView.alpha = 1
                largeImageView.frame = largeImageViewFrame
            }, completion: { (_) in
                fromView.removeFromSuperview()
                largeImageView.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        }
    }
    
}
