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
        imageview.clipsToBounds = true
        return imageview
    }()
    private lazy var indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    private lazy var dimmingButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        button.backgroundColor = UIColor(white: 0, alpha: 0.4)
        button.isHidden = true
        button.addTarget(self, action: #selector(dimmingButtonAction), for: .touchUpInside)
        return button
    }()
    private lazy var sheetTableView: UITableView = {
        let tableview = UITableView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth , height: 80), style: .plain)
        tableview.backgroundColor = .yellow
        return tableview
    }()
    
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
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureAction))
        view.addGestureRecognizer(longPressGesture)
        
        browseScrollView.alpha = 0
        browseImageView.alpha = 0
        
        view.addSubview(browseScrollView)
        view.addSubview(indicatorView)
        view.addSubview(sheetTableView)
        
        browseScrollView.addSubview(browseImageView)
        browseScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        browseImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
                    self.updateZoomScale()
                }
            }
            }.resume()
    }
    
    func updateZoomScale() {
        // 让 imageView 根据图片大小自适应
        browseImageView.sizeToFit()
        
        // 设置缩放系数，否则下一步获取不到 contentSize
        browseScrollView.minimumZoomScale = 1
        browseScrollView.maximumZoomScale = 2
        browseScrollView.zoomScale = 1
        
        // 让最小缩放系数下图片宽度和屏幕相同，这样比较美观
        let zoomScale = view.bounds.width / browseScrollView.contentSize.width
        browseScrollView.minimumZoomScale = zoomScale;
        
        // 设置缩放比率，这里会触发 scrollViewDidZoom 代理方法
        browseScrollView.zoomScale = zoomScale
    }
    
}

extension BrowseViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return browseImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // 在手动缩放时根据 imageView 实时尺寸调整 contentInset 使之始终能保持居中显示
        let screenSize = view.bounds.size;
        let paddingH = max((screenSize.width - browseImageView.frame.width) / 2, 0);
        let paddingV = max((screenSize.height - browseImageView.frame.height) / 2, 0);
        scrollView.contentInset = UIEdgeInsetsMake(paddingV, paddingH, paddingV, paddingH);
    }
    
}

extension BrowseViewController {
    
    @objc func oneTapAtion() {
        if isZoom {
            isZoom = false
            browseScrollView.setZoomScale(browseScrollView.minimumZoomScale, animated: true)
        } else {
            dismissClosure?()
        }
    }
    
    @objc func doubleTapAction(recognizer: UITapGestureRecognizer) {
        isZoom = !isZoom
        switch isZoom {
        case true:
            let point = recognizer.location(in: self.browseScrollView)
            browseScrollView.zoom(to: CGRect(origin: point, size: CGSize(width: 1, height: 1)), animated: true)
        case false:
             browseScrollView.setZoomScale(browseScrollView.minimumZoomScale, animated: true)
        }
    }
    
    @objc func longPressGestureAction() {
        dimmingButton.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.sheetTableView.transform = CGAffineTransform(translationX: 0, y: -80)
        }
    }
    
    @objc func dimmingButtonAction() {
        dimmingButton.isHidden = true
        UIView.animate(withDuration: 0.25) {
            self.sheetTableView.transform = .identity
        }
    }
    
}
