//
//  AlbumsViewController.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/10/18.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

class AlbumsViewController: UIViewController {
    
    lazy var albumsTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.register(AlbumsCell.self, forCellReuseIdentifier: AlbumsCellID)
        tableView.rowHeight = 60
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

}

// MARK: - ConfigureUI
extension AlbumsViewController {
    
    func configureUI() {
        title = "相册"
        
        view.addSubview(albumsTableView)
        albumsTableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.topLayoutGuide.snp.bottom)
            $0.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
    }
    
}

extension AlbumsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumsCellID, for: indexPath) as! AlbumsCell
        return cell
    }
}
