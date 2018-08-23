//
//  BrowseViewController.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/8/23.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

class BrowseViewController: UIViewController {
    
    var startRect: CGRect?
    var isZoom: Bool = false
    
    private lazy var browseScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        return scrollView
    }()
     lazy var browseImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.clipsToBounds = true
        return imageview
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         configureUI()
    }
    
    private func configureUI() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapDismissAction))
        view.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        tap.require(toFail: doubleTap)
        
        view.addSubview(browseScrollView)
        browseScrollView.addSubview(browseImageView)
    }
    
    func loadLargeImageData(largeImageString: String) {
        guard let imageUrl = URL(string: largeImageString) else { return }
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        view.addSubview(indicatorView)
        indicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        indicatorView.startAnimating()
        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
            DispatchQueue.main.async {
                indicatorView.removeFromSuperview()
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
    
    func setStarRect(rect: CGRect, image: UIImage) {
        startRect = rect
       browseImageView.image = image
        browseScrollView.frame = rect
        browseImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.size.equalTo(CGSize(width: rect.width, height: rect.height))
        }

        let scale = screenWidth / rect.width

        UIView.animate(withDuration: 0.25, animations: {
            var transform2 = CGAffineTransform(scaleX: scale, y: scale)
            transform2.tx = self.view.center.x - rect.midX
            transform2.ty =  self.view.center.y - rect.midY
            self.browseScrollView.transform = transform2
        }) { (_) in
            print("动画结束")
        }
    }

}

extension BrowseViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return browseImageView
    }
}

extension BrowseViewController {
    
    // 单点手势
    @objc func tapDismissAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // 双击手势
    @objc func doubleTapAction(recognizer: UITapGestureRecognizer) {
        let scale = screenWidth / startRect!.width
        isZoom = !isZoom
        switch isZoom {
        case true:
            UIView.animate(withDuration: 0.25, animations: {
                var transform2 = CGAffineTransform(scaleX: scale * 2, y: scale * 2)
                transform2.tx = self.view.center.x - self.startRect!.midX
                transform2.ty =  self.view.center.y - self.startRect!.midY
                self.browseScrollView.transform = transform2
            }) { (_) in
                print("动画结束")
            }
            browseScrollView.contentSize = CGSize(width: screenWidth * 2, height: screenWidth * 2)
        case false:
            UIView.animate(withDuration: 0.25, animations: {
                var transform2 = CGAffineTransform(scaleX: scale, y: scale)
                transform2.tx = self.view.center.x - self.startRect!.midX
                transform2.ty =  self.view.center.y - self.startRect!.midY
                self.browseScrollView.transform = transform2
            }) { (_) in
                print("动画结束")
            }
        }
     
    }
    
}
