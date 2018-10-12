//
//  DisplayViewController.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/10/12.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

class DisplayViewController: UIViewController {
    
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
        tableView.estimatedRowHeight = 200
        tableView.register(NewsDetailCell.self, forCellReuseIdentifier: NewsDetailCellID)
        return tableView
    }()

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
    }
    
}

// MARK: - UITableViewDataSource
extension DisplayViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsDetailCellID, for: indexPath)
        return cell
    }
}

// MARK: - Event response
extension DisplayViewController {
    
    @objc func dismissButtonAction() {
        dismiss(animated: true, completion: nil)
    }
}
