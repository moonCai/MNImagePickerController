//
//  BrowseViewController.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/8/23.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit

class BrowseViewController: UIViewController {
    
    var titles: [String] = []
    
    let saveCellID = "saveCellID"
    
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
        let tableview = UITableView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth , height: 100), style: .plain)
        tableview.backgroundColor = .yellow
        tableview.register(SheetTableCell.self, forCellReuseIdentifier: saveCellID)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.rowHeight = 45
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
        view.addSubview(dimmingButton)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
        titles = ["保存图片", "取消"]
        sheetTableView.reloadData()
        UIView.animate(withDuration: 0.25) {
            self.sheetTableView.transform = CGAffineTransform(translationX: 0, y: -100)
        }
    }
    
    @objc func dimmingButtonAction() {
        UIView.animate(withDuration: 0.25, animations: {
           self.sheetTableView.transform = .identity
        }) { (_) in
            self.dimmingButton.isHidden = true
        }
    }
    
}

extension BrowseViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count == 0 ? 0 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard titles.count != 0 else { return 0 }
        if section == 0 {
            return titles.count - 1
        } else if section == 1 {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: saveCellID, for: indexPath) as! SheetTableCell
        if indexPath.section == 0 {
            cell.titleLabel.text = titles[indexPath.row]
        } else {
            cell.titleLabel.text = titles.last
        }
        return cell
    }
}

extension BrowseViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            UIView.animate(withDuration: 0.25, animations: {
                self.sheetTableView.transform = .identity
            }) { (_) in
                self.dimmingButton.isHidden = true
            }
        } else {
            print(indexPath.row)
            UIView.animate(withDuration: 0.25, animations: {
                self.sheetTableView.transform = .identity
            }) { (_) in
                self.dimmingButton.isHidden = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView()
            view.backgroundColor = .groupTableViewBackground
            return view
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 10 : 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
}

class SheetTableCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
}
