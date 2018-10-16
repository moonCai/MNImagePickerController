//
//  DisplayViewController.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/10/12.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit
import MobileCoreServices
import AssetsLibrary
import AVFoundation

class DisplayViewController: UIViewController {
    
    var selectedImages: [UIImage] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var isVideo: Bool = false
    
    var selectedVideoPath: String = "" {
        didSet {
             let videoURL = URL(fileURLWithPath: selectedVideoPath)
            let firstFrame = getFirstVideoFrameWith(videoPath: videoURL, size: CGSize(width: screenWidth, height: screenHeight))
            if firstFrame != nil {
                selectedImages.append(firstFrame!)
                isVideo = true
            }
        }
    }
    
    private lazy var pickerController: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.delegate = self
        return controller
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(dismissButtonAction), for: .touchUpInside)
        return button
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 230
        tableView.register(NewsDetailCell.self, forCellReuseIdentifier: NewsDetailCellID)
        return tableView
    }()
    lazy var dimmingButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        button.backgroundColor = UIColor(white: 0, alpha: 0.4)
        button.isHidden = true
        button.addTarget(self, action: #selector(dimmingButtonAction), for: .touchUpInside)
        return button
    }()
    lazy var mediaChooseSheetView = MediaChooseSheetView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
    }
    
}

// MARK: - ConfigureUI
extension DisplayViewController {
    
    func configureUI() {
        view.addSubview(dismissButton)
        view.addSubview(tableView)
        view.addSubview(dimmingButton)
        view.addSubview(mediaChooseSheetView)
        
        dismissButton.snp.makeConstraints {
            $0.top.equalTo(self.topLayoutGuide.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(15)
            $0.size.equalTo(CGSize(width: 40, height: 25))
        }
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(70)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.bottomLayoutGuide.snp.top)
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
            case .shoot:  // 拍照
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
                    let imageType = kUTTypeImage as String
                    if availableMediaTypes.contains(imageType) {
                        self.pickerController.sourceType = .camera
                        self.pickerController.mediaTypes = [imageType]
                        self.present(self.pickerController, animated: true, completion: nil)
                    }
                }
            case .album: // 从相册选择
                let controller = MutiplePhotoAlbumController()
                let navigationController = UINavigationController(rootViewController: controller)
                self.present(navigationController, animated: true, completion: nil)
            case .cancel:
                print("取消")
            }
        }
        
        dimmingButton.isHidden = true
    }
    
}

// MARK: - UITableViewDataSource
extension DisplayViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsDetailCellID, for: indexPath) as! NewsDetailCell
        cell.isVideo = isVideo
        cell.selectedImages = selectedImages
        cell.selectClsoure = { [unowned self] selectedIndex in
            if self.selectedImages.count < 9, selectedIndex == self.selectedImages.count {
                self.dimmingButton.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    self.mediaChooseSheetView.transform = CGAffineTransform(translationX: 0, y: -175)
                }
            } else {
                print("浏览图片")
            }
        }
        return cell
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension DisplayViewController:  UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let originImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        UIImageWriteToSavedPhotosAlbum(originImage, self, #selector(self.didFinishSavingPhoto(image:error:observationInfo:)), nil)
    }
}

// MARK: - Event response
extension DisplayViewController {
    
    // - 点击取消
    @objc func dismissButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // - 点击蒙版
    @objc func dimmingButtonAction() {
        UIView.animate(withDuration: 0.25, animations: {
            self.mediaChooseSheetView.transform = .identity
        }) { (_) in
            self.dimmingButton.isHidden = true
        }
    }
    
    // - 保存照片到系统相册的监听回调
    @objc func didFinishSavingPhoto(image: UIImage, error: Error?, observationInfo: UnsafeMutableRawPointer) {
        if error != nil {
            let alertController = UIAlertController(title: "保存失败: \(error?.localizedDescription ?? "")", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "知道了", style: .cancel, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        } else {
            selectedImages.append(image)
        }
    }

    // - 获取本地视频第一桢
    func getFirstVideoFrameWith(videoPath: URL, size: CGSize)->UIImage?  {
        let videoAsset = AVURLAsset(url: videoPath, options: nil)
        let generator = AVAssetImageGenerator(asset: videoAsset)
        generator.appliesPreferredTrackTransform = true
        do {
            let img = try generator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 600), actualTime: nil)
            return UIImage(cgImage: img)
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
}
