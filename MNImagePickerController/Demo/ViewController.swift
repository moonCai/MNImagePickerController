//
//  ViewController.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/8/22.
//  Copyright © 2018年 T. All rights reserved.
// 

import UIKit
import SnapKit
import MobileCoreServices
import AssetsLibrary

class ViewController: UIViewController {
    
    // 动画器
    var animator = TransitionAnimator()
    
    // 单图被点击时在屏幕上的位置
    private var portraitCurrentRect = CGRect()
    // 缩略图
    private lazy var portraitImage = UIImage(named: "rect_portrait")!
    
    private lazy var headerView = NewsTableHeaderView()
    private lazy var portraitImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "portrait")
        return imageView
    }()
    private lazy var newsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.rowHeight = 120
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCellID)
        return tableView
    }()
    private lazy var dimmingButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        button.backgroundColor = UIColor(white: 0, alpha: 0.4)
        button.isHidden = true
        button.addTarget(self, action: #selector(dimmingButtonAction), for: .touchUpInside)
        return button
    }()
    private lazy var mediaChooseSheetView = MediaChooseSheetView()
    private lazy var indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    private lazy var pickerController: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.delegate = self
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigationUI()
        loadPortraitImageData()
    }
    
}

// MARK: - Configure UI
extension ViewController {
    
    private func configureNavigationUI() {
        let clearImage = UIImage.createImageByColor(color: .clear)
        navigationController?.navigationBar.shadowImage = clearImage
        navigationController?.navigationBar.setBackgroundImage(clearImage, for: .default)
        
        if #available(iOS 11.0, *) {
            newsTableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    private func configureUI() {
        view.addSubview(newsTableView)
        view.addSubview(indicatorView)
        view.addSubview(dimmingButton)
        view.addSubview(mediaChooseSheetView)
        
        headerView.frame.size.height = 3 * screenWidth / 4 + 40
        newsTableView.tableHeaderView = headerView
        
        headerView.portraitButton.addTarget(self, action: #selector(portraitButtonAction(sender:)), for: .touchUpInside)
        
        newsTableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
        indicatorView.snp.makeConstraints {
            $0.center.equalTo(headerView.portraitButton)
        }
        dimmingButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        mediaChooseSheetView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.snp.bottom)
            $0.height.equalTo(175)
        }
        
        mediaChooseSheetView.mediaTypeClosure = { [unowned self] type in
            self.dimmingButtonAction()
            switch type {
            case .shoot:  // 拍照 / 拍视频
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
                    let imageType = kUTTypeImage as String
                    let videoType = kUTTypeMovie as String
                    if availableMediaTypes.contains(imageType), availableMediaTypes.contains(videoType) {
                        self.pickerController.sourceType = .camera
                        self.pickerController.mediaTypes = [imageType, videoType]
                        self.present(self.pickerController, animated: true, completion: nil)
                    }
                }
            case .album: // 从相册选择
                print("从相册选择")
            case .cancel:
                print("取消")
            }
        }
        
        dimmingButton.isHidden = true
        indicatorView.startAnimating()
    }
    
}

// MARK: - 加载图片
extension ViewController {
    
    private func loadPortraitImageData() {
        guard let url = URL(string: portraitThumb) else { return }
        URLSession.shared.dataTask(with: url) { [unowned self] (data, response, error) in
            DispatchQueue.main.async {
                self.indicatorView.removeFromSuperview()
            }
            if error != nil {
                print(error?.localizedDescription ?? "头像下载失败")
            } else if let imageData = data {
                DispatchQueue.main.async {
                    if let image = UIImage(data: imageData) {
                        self.portraitImage = image
                        self.headerView.portraitButton.setImage(image, for: .normal)
                    }
                }
            }
            }.resume()
    }
    
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCellID, for: indexPath) as! NewsTableViewCell
        cell.cameraButton.addTarget(self, action: #selector(cameraButtonAction(sender:)), for: .touchUpInside)
        return cell
    }
}

extension ViewController {
    
    @objc func portraitButtonAction(sender: UIButton) {
        let thumbnailSize = (sender.imageView?.image?.size)!
        portraitCurrentRect = sender.convert(sender.frame, to: view)
        let scale = (thumbnailSize.width / thumbnailSize.height) / (sender.bounds.width / sender.bounds.height)
        if scale > 1 { // 宽度被裁切
            portraitCurrentRect = CGRect(x: portraitCurrentRect.origin.x - (scale - 1) * portraitCurrentRect.width / 2 , y: portraitCurrentRect.origin.y, width: portraitCurrentRect.width * scale, height: portraitCurrentRect.height)
        } else if scale < 1 { // 长度被裁切
            portraitCurrentRect = CGRect(x: portraitCurrentRect.origin.x , y: portraitCurrentRect.origin.y - (scale - 1) * portraitCurrentRect.height / 2 , width: portraitCurrentRect.width, height: portraitCurrentRect.height / scale)
        }

        let controller = SimpleImageBrowseViewController()
        controller.transitioningDelegate = self
        // 大图 / 缩略图 / 初始位置
        controller.photoURLString = portraitLarge
//        controller.loadLargeImageData(largeImageString: portraitLarge)
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func cameraButtonAction(sender: UIButton) {
        dimmingButton.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.mediaChooseSheetView.transform = CGAffineTransform(translationX: 0, y: -175)
        }
    }
    
    @objc func dimmingButtonAction() {
        UIView.animate(withDuration: 0.25, animations: {
            self.mediaChooseSheetView.transform = .identity
        }) { (_) in
            self.dimmingButton.isHidden = true
        }
    }
    
    // 保存照片到系统相册的回调
    @objc func didFinishSavingPhoto(image: UIImage, error: Error?, observationInfo: UnsafeMutableRawPointer) {
        if error != nil {
            print("保存失败")
        } else {
            print("❤️❤️已保存到系统相册❤️❤️")
        }
    }
    
}

extension ViewController:  UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let mediaType = info["UIImagePickerControllerMediaType"] as? String else { return }
        if mediaType == "public.movie" {
            guard let videoFileURL = info["UIImagePickerControllerMediaURL"] as? URL else { return }
            ALAssetsLibrary().writeVideoAtPath(toSavedPhotosAlbum: videoFileURL) { (videoURL, error) in
                if error != nil {
                    print("视频保存失败")
                } else {
                    print(videoURL)
                }
            }
        } else if mediaType == "public.image" {
            let originImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
            UIImageWriteToSavedPhotosAlbum(originImage, self, #selector(self.didFinishSavingPhoto(image:error:observationInfo:)), nil)
        }
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.type = .dismiss
        return animator
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.type = .modal
        animator.portraitImage = self.portraitImage
        animator.portraitCurrentRect = portraitCurrentRect
        return animator
    }
}




