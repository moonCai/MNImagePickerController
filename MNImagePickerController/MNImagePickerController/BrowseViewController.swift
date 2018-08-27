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
        scrollView.maximumZoomScale = 2
        scrollView.minimumZoomScale = 1
        return scrollView
    }()
    lazy var browseImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "rect_portrait")!
        imageview.contentMode = .scaleAspectFit
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
            $0.edges.equalToSuperview()
        }
        browseImageView.snp.makeConstraints {
            $0.edges.size.equalToSuperview()
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
    
    @objc func oneTapAtion() {
        dismissClosure?()
    }
    
    @objc func doubleTapAction(recognizer: UITapGestureRecognizer) {
        isZoom = !isZoom
        switch isZoom {
        case true:
            let point = recognizer.location(in: self.browseScrollView)
            browseScrollView.zoom(to: CGRect(origin: point, size: CGSize(width: 1, height: 1)), animated: true)
            browseScrollView.setZoomScale(2, animated: true)
        case false:
            browseScrollView.setZoomScale(1, animated: true)
        }
    }
    
}
