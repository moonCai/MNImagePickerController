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
    lazy var portraitImage = UIImage(named: "rect_portrait")!
    // 单图被点击时在屏幕上的位置
    var portraitCurrentRect = CGRect()
}

extension TransitionAnimator: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        type = .modal
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        type = .dismiss
        return self
    }
}

extension TransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        let containerView = transitionContext.containerView
        transitionContext.containerView.addSubview(toView!)
        
        switch type {
        case .modal:
            let toController = transitionContext.viewController(forKey: .to) as! SimpleImageBrowseViewController
            
            let snapshotView = UIImageView(image: portraitImage)
            snapshotView.contentMode = .scaleAspectFill
            snapshotView.clipsToBounds = true
            
            snapshotView.frame = self.portraitCurrentRect
            containerView.addSubview(snapshotView)
            
            let zoomScale = screenWidth / portraitCurrentRect.width
            
            var tran = CATransform3DIdentity
            let translateX = screenWidth / 2 - portraitCurrentRect.midX
            let translateY = screenHeight / 2 - portraitCurrentRect.midY
            tran = CATransform3DTranslate(tran, translateX, translateY, 50)
            tran.m34 = -1 / 1000.0
            tran = CATransform3DScale(tran, zoomScale, zoomScale, 1)
            
            toView?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            UIView.animate(withDuration:transitionDuration(using: nil) * 0.5, animations: {
                snapshotView.layer.transform = tran
                fromView?.alpha = 0
            }, completion: { (_) in
                fromView?.removeFromSuperview()
                UIView.animate(withDuration: self.transitionDuration(using: nil) * 0.5, animations: {
                    toController.opaqueSubviews()
                }, completion: { (_) in
                    snapshotView.removeFromSuperview()
                    transitionContext.completeTransition(true)
                })
            })
            
        case .dismiss:
            let fromController = transitionContext.viewController(forKey: .from) as! SimpleImageBrowseViewController
            
            let imageView = fromController.browseImageView
            
            let snapshotView = UIImageView(image: imageView.image)
            snapshotView.clipsToBounds = true
            snapshotView.contentMode = .scaleAspectFill
            
            snapshotView.frame = containerView.convert(imageView.frame, from: imageView.superview)
            containerView.addSubview(snapshotView)
            
            fromView?.removeFromSuperview()
            
            let zoomScale = portraitCurrentRect.width / screenWidth
            
            var tran = CATransform3DIdentity
            let translateX = self.portraitCurrentRect.midX - screenWidth / 2
            let translateY = self.portraitCurrentRect.midY -  screenHeight / 2
            tran = CATransform3DTranslate(tran, translateX, translateY, -50)
            tran.m34 = -1 / 1000.0
            
            tran = CATransform3DScale(tran, zoomScale, zoomScale, 1)

            UIView.animate(withDuration: self.transitionDuration(using: nil) * 0.5, animations: {
                snapshotView.layer.transform = tran
                toView?.alpha = 1
            }, completion: { (_) in
                snapshotView.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        }
    }
    
    
}
