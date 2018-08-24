//
//  BrowseViewController.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/8/23.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

class BrowseViewController: UIViewController {
    
    // 是否是放大状态
    var isZoom: Bool = false

    var dismissClosure: (()->())?
    
     lazy var browseScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        return scrollView
    }()
     lazy var browseImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "rect_portrait")!
        imageview.contentMode = .scaleAspectFill
        imageview.clipsToBounds = true
        return imageview
    }()
      private lazy var indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
         configureUI()
    }
    
     private func configureUI() {
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(oneTapAtion))
        view.addGestureRecognizer(oneTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        oneTap.require(toFail: doubleTap)
        
        browseScrollView.alpha = 0
        browseImageView.alpha = 0
        
        view.addSubview(browseScrollView)
        view.addSubview(indicatorView)
   
        browseScrollView.addSubview(browseImageView)
        browseScrollView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(CGSize(width: screenWidth, height: screenWidth))
        }
        browseImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(CGSize(width: screenWidth, height: screenWidth))
        }
        indicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func opaqueSubviews() {
        browseScrollView.alpha = 1
        browseImageView.alpha = 1
    }
    
    func loadLargeImageData(largeImageString: String) {
        guard let imageUrl = URL(string: largeImageString) else { return }
        indicatorView.startAnimating()
        URLSession.shared.dataTask(with: imageUrl) { [unowned self] (data, response, error) in
            DispatchQueue.main.async {
                self.indicatorView.removeFromSuperview()
            }
            if error != nil {
                print(error?.localizedDescription ?? "加载大图失败")
            } else if let largeImageData = data {
                DispatchQueue.main.async {
                    let largeImage = UIImage(data: largeImageData)
                    self.browseImageView.image = largeImage
                }
            }
        }.resume()
    }
}

extension BrowseViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return browseImageView
    }
}

extension BrowseViewController {
    
     // 单击手势
    @objc func oneTapAtion() {
        dismissClosure?()
    }
    
    // 双击手势
    @objc func doubleTapAction(recognizer: UITapGestureRecognizer) {
        isZoom = !isZoom
        switch isZoom {
        case true:
            UIView.animate(withDuration: 0.5, animations: {
                self.browseScrollView.transform = CGAffineTransform(scaleX: 2, y: 2)
//                self.browseImageView.transform  = CGAffineTransform(scaleX: 2, y: 2)
            }) { (_) in
                print("动画结束")
            }
            self.browseScrollView.contentSize = CGSize(width: screenWidth * 3, height: screenWidth * 4 - screenHeight)
        case false:
            UIView.animate(withDuration: 0.5, animations: {
                self.browseScrollView.transform = .identity
                self.browseImageView.transform = .identity
            }) { (_) in
                print("动画结束")
            }
        }
    }
}
