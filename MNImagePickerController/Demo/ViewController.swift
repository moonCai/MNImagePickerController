//
//  ViewController.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/8/22.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit
import SnapKit

let newsCell_ID = "newsCell_ID"
let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height
class ViewController: UIViewController {
    
    private lazy var headerImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "cup")
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var portraitImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "portrait")
        return imageView
    }()
    
    private lazy var newsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        return tableView
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle { get { return.lightContent }}

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigationUI()
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
      headerImageView.addSubview(portraitImageView)
        
      headerImageView.frame.size.height = 3 * screenWidth / 4
      newsTableView.tableHeaderView = headerImageView
        
        newsTableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
        portraitImageView.snp.makeConstraints {
            $0.centerY.equalTo(headerImageView.snp.bottom)
            $0.trailing.equalToSuperview().offset(-20)
            $0.size.equalTo(CGSize(width: 80, height: 80))
        }
        
    }
    
}

