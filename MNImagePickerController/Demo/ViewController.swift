//
//  ViewController.swift
//  MNImagePickerController
//
//  Created by 瓷月亮 on 2018/8/22.
//  Copyright © 2018年 T. All rights reserved.
//

import UIKit
import SnapKit

let NewsTableViewCell_ID = "NewsTableViewCell_ID"
let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height

enum MNAnimatorType {
    case modal
    case dismiss
}

class ViewController: UIViewController {
    
    // 转场类型
    private var type: MNAnimatorType = .modal
    // 头像被点击时在屏幕上的位置
    private var portraitCurrentRect: CGRect = CGRect()
    private lazy var portraitImage: UIImage = UIImage(named: "rect_portrait")!
    
    private lazy var headerView: NewsTableHeaderView = NewsTableHeaderView()
    
    private lazy var portraitImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "portrait")
        return imageView
    }()
    
    private lazy var newsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.rowHeight = 120
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell_ID)
        return tableView
    }()
    
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
        
        headerView.frame.size.height = 3 * screenWidth / 4 + 40
        newsTableView.tableHeaderView = headerView
        
        headerView.portraitButton.addTarget(self, action: #selector(portraitButtonAction(sender:)), for: .touchUpInside)
        
        newsTableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
    }
    
    private func loadPortraitImageData() {
        guard let url = URL(string: portraitThumb) else { return }
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        view.addSubview(indicatorView)
        indicatorView.snp.makeConstraints {
            $0.center.equalTo(headerView.portraitButton)
        }
        indicatorView.startAnimating()
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                 indicatorView.removeFromSuperview()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell_ID, for: indexPath) as! NewsTableViewCell
        cell.cameraButton.addTarget(self, action: #selector(cameraButtonAction(sender:)), for: .touchUpInside)
        return cell
    }
}

extension ViewController {
    
    @objc func portraitButtonAction(sender: UIButton) {
        let currentRect = sender.convert(sender.frame, to: view)
        portraitCurrentRect = currentRect
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
        transitionContext.containerView.addSubview(toView!)
        
        var imageView: UIImageView = UIImageView()
    
        switch type {
        case .modal:
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissTapAction))
            toView?.addGestureRecognizer(tap)
            
            let image = self.headerView.portraitButton.toRetinaImageInRect()
            imageView = UIImageView(image: image)
            imageView.frame = self.portraitCurrentRect
            transitionContext.containerView.addSubview(imageView)
            
            let zoomScale = screenWidth / portraitCurrentRect.width
             
            var tran = CATransform3DIdentity
             let translateX = screenWidth / 2 - self.portraitCurrentRect.midX
             let translateY = screenHeight / 2 - self.portraitCurrentRect.midY
             tran = CATransform3DTranslate(tran, translateX, translateY, 50)
            tran.m34 = -1 / 1000.0
            tran = CATransform3DScale(tran, zoomScale, zoomScale, 1)
      
            toView?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            toView?.transform = CGAffineTransform(translationX: 0, y: (toView?.bounds.size.height)!)
            UIView.animate(withDuration:transitionDuration(using: nil) * 0.5, animations: {
                imageView.layer.transform = tran
                fromView?.alpha = 0
                toView?.transform = .identity
            }, completion: { (_) in
                fromView?.removeFromSuperview()
                guard let toController = transitionContext.viewController(forKey: .to) as? BrowseViewController else { return }
                UIView.animate(withDuration: self.transitionDuration(using: nil) * 0.5, animations: {
                    toController.opaqueSubviews()
                }, completion: { (_) in
                    imageView.removeFromSuperview()
                    transitionContext.completeTransition(true)
                })
            })
            
        case .dismiss:
            transitionContext.containerView.insertSubview(toView!, belowSubview: fromView!)
            
            guard let fromController = transitionContext.viewController(forKey: .from) as? BrowseViewController else { return }
            let image = fromController.browseImageView.toRetinaImageInRect()
            imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: (screenHeight - screenWidth) / 2, width: screenWidth, height: screenWidth)
            transitionContext.containerView.addSubview(imageView)
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
                imageView.layer.transform = tran
                toView?.alpha = 1
                self.headerView.portraitButton.alpha = 1
            }, completion: { (_) in
                imageView.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        }
    }
    
    @objc func dismissTapAction() {
        dismiss(animated: true, completion: nil)
    }
}

