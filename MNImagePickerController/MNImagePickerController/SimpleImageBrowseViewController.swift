//
//  SimpleImageBrowseViewController.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/9/28.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

class SimpleImageBrowseViewController: UIViewController {

    // 单图被点击时在屏幕上的位置
    var portraitCurrentRect = CGRect()
    // 缩略图
    lazy var portraitImage = UIImage()
    // 是否是放大状态
    var isZoom: Bool = false
    
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
    private lazy var sheetView = SaveSheetView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth , height: 120))
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(thumbImage: UIImage, photoString: String, animatatedFromView animatedView: UIView) {
        self.init()
        loadLargeImageData(largeImageString: photoString)
        
        let thumbnailSize = thumbImage.size
        portraitCurrentRect = animatedView.convert(animatedView.frame, to: view)
        portraitImage = thumbImage
        
        let scale = (thumbnailSize.width / thumbnailSize.height) / (animatedView.bounds.width / animatedView.bounds.height)
        if scale > 1 { // 宽度被裁切
            portraitCurrentRect = CGRect(x: portraitCurrentRect.origin.x - (scale - 1) * portraitCurrentRect.width / 2 , y: portraitCurrentRect.origin.y, width: portraitCurrentRect.width * scale, height: portraitCurrentRect.height)
        } else if scale < 1 { // 长度被裁切
            portraitCurrentRect = CGRect(x: portraitCurrentRect.origin.x , y: portraitCurrentRect.origin.y - (scale - 1) * portraitCurrentRect.height / 2 , width: portraitCurrentRect.width, height: portraitCurrentRect.height / scale)
        }
    }
    
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
        view.addSubview(dimmingButton)
        view.addSubview(sheetView)
        
        sheetView.sheetClosure = { [unowned self] sheetType in
            switch sheetType {
            case .save:
                UIImageWriteToSavedPhotosAlbum(self.browseImageView.image!, self, #selector(self.didFinishSavingPhoto(image:error:observationInfo:)), nil)
            case .cancel:
                print("取消保存")
            default:
                print("sheetType")
            }
            UIView.animate(withDuration: 0.25, animations: {
                self.sheetView.transform = .identity
            }) { (_) in
                self.dimmingButton.isHidden = true
            }
        }
        
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
    
    @objc func didFinishSavingPhoto(image: UIImage, error: Error?, observationInfo: UnsafeMutableRawPointer) {
        if error != nil {
            print("保存失败")
        } else {
            print("❤️❤️已保存到系统相册❤️❤️")
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

extension SimpleImageBrowseViewController: UIScrollViewDelegate {
    
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

extension SimpleImageBrowseViewController {
    
    @objc func oneTapAtion() {
        if isZoom {
            isZoom = false
            browseScrollView.setZoomScale(browseScrollView.minimumZoomScale, animated: true)
        } else {
            dismiss(animated: true, completion: nil)
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
            self.sheetView.transform = CGAffineTransform(translationX: 0, y: -120)
        }
    }
    
    @objc func dimmingButtonAction() {
        UIView.animate(withDuration: 0.25, animations: {
            self.sheetView.transform = .identity
        }) { (_) in
            self.dimmingButton.isHidden = true
        }
    }
    
}




