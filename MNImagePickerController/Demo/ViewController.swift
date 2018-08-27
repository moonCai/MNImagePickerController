//
//  ViewController.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/8/22.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit
import SnapKit

enum MNAnimatorType {
    case modal
    case dismiss
}

class ViewController: UIViewController {
    
    // 转场类型
    private var type: MNAnimatorType = .modal
    // 头像被点击时在屏幕上的位置
    private var portraitCurrentRect = CGRect()
    private lazy var portraitImage = UIImage(named: "rect_portrait")!
    
    let CellID = "CellID"
    
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
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: CellID)
        return tableView
    }()
    private lazy var indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    override var preferredStatusBarStyle: UIStatusBarStyle { get { return.lightContent }}
    
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
        
        indicatorView.startAnimating()
    }
    
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
                        self.headerView.portraitButton.setBackgroundImage(image, for: .normal)
                    } 
                }
            }
            }.resume()
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID, for: indexPath) as! NewsTableViewCell
        cell.cameraButton.addTarget(self, action: #selector(cameraButtonAction(sender:)), for: .touchUpInside)
        return cell
    }
}

extension ViewController {
    
    @objc func portraitButtonAction(sender: UIButton) {
        portraitCurrentRect = sender.convert(sender.frame, to: view)
        let controller = BrowseViewController()
        controller.transitioningDelegate = self
        controller.loadLargeImageData(largeImageString: portraitLarge)
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func cameraButtonAction(sender: UIButton) {
        print("cameraButtonAction")
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        type = .modal
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        type = .dismiss
        return self
    }
}

extension ViewController: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        let containerView = transitionContext.containerView
        transitionContext.containerView.addSubview(toView!)
        
        switch type {
        case .modal:
            let toController = transitionContext.viewController(forKey: .to) as! BrowseViewController
            toController.dismissClosure = { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }
            
            let snapshotView = UIImageView(image: portraitImage)
            snapshotView.contentMode = .scaleAspectFill
            snapshotView.clipsToBounds = true
            
            var scale: CGFloat = 1
            var originSize: CGSize = CGSize(width: 1, height: 1)
            if snapshotView.bounds.size.width > snapshotView.bounds.size.height {
                scale = snapshotView.bounds.size.width / snapshotView.bounds.size.height
                originSize = CGSize(width:  portraitCurrentRect.width * scale, height:  portraitCurrentRect.width)
            } else {
                scale = snapshotView.bounds.size.height / snapshotView.bounds.size.width
                originSize = CGSize(width:  portraitCurrentRect.width, height:  portraitCurrentRect.width * scale)
            }
            
            snapshotView.frame.origin = self.portraitCurrentRect.origin
            snapshotView.frame.size = originSize
            containerView.addSubview(snapshotView)
            
            let zoomScale = screenWidth / portraitCurrentRect.width
            
            var tran = CATransform3DIdentity
            let translateX = screenWidth / 2 - snapshotView.frame.midX
            let translateY = screenHeight / 2 - snapshotView.frame.midY
            tran = CATransform3DTranslate(tran, translateX, translateY, 50)
            tran.m34 = -1 / 1000.0
            tran = CATransform3DScale(tran, zoomScale, zoomScale, 1)
            
            toView?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            UIView.animate(withDuration:transitionDuration(using: nil) * 0.5, animations: {
                snapshotView.layer.transform = tran
                fromView?.alpha = 0
            }, completion: { (_) in
                fromView?.removeFromSuperview()
                UIView.animate(withDuration: self.transitionDuration(using: nil) * 0.5, animations: {
                    toController.opaqueSubviews()
                }, completion: { (_) in
                    snapshotView.removeFromSuperview()
                    transitionContext.completeTransition(true)
                })
            })
            
        case .dismiss:
            let fromController = transitionContext.viewController(forKey: .from) as! BrowseViewController
            
            let imageView = fromController.browseImageView
            
            let snapshotView = UIImageView(image: imageView.image)
            snapshotView.clipsToBounds = true
            snapshotView.contentMode = .scaleAspectFill
            
            snapshotView.frame = containerView.convert(imageView.frame, from: imageView.superview)
            containerView.addSubview(snapshotView)
            
            fromView?.removeFromSuperview()

            let zoomScale = portraitCurrentRect.width / screenWidth
            
            var tran = CATransform3DIdentity
            let translateX = self.portraitCurrentRect.midX - screenWidth / 2
            let translateY = self.portraitCurrentRect.midY -  screenHeight / 2
            tran = CATransform3DTranslate(tran, translateX, translateY, -50)
            tran.m34 = -1 / 1000.0
            
            tran = CATransform3DScale(tran, zoomScale, zoomScale, 1)
            self.headerView.portraitButton.alpha = 0
            
            UIView.animate(withDuration: self.transitionDuration(using: nil) * 0.5, animations: {
                snapshotView.layer.transform = tran
                toView?.alpha = 1
                self.headerView.portraitButton.alpha = 1
            }, completion: { (_) in
                snapshotView.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        }
    }
    
}

