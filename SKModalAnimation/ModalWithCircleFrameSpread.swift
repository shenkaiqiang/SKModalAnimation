//
//  ModalWithCircleFrameSpread.swift
//  shen
//
//  Created by 沈凯强 on 2021/01/01.
//  Copyright © 2021 mn. All rights reserved.
//

import UIKit

class ModalWithCircleFrameSpread: ModalAnimationManager {
    
    private var startView:UIView?
    private var centerPoint = CGPoint.zero
    
    convenience init(startPoint:CGPoint) {
        self.init()
        self.centerPoint = startPoint
    }
    private override init() {
        super.init()
    }
    
    private func frameToCircle(centerPoint:CGPoint, size:CGSize) -> CGRect {
        let radiusX = CGFloat.maximum(centerPoint.x, size.width-centerPoint.x)
        let radiusY = CGFloat.maximum(centerPoint.y, size.height-centerPoint.y)
        let endRadius = sqrtf(powf(Float(radiusX), 2)+powf(Float(radiusY), 2)) * 2
        let fRadius = CGFloat(endRadius)
        let rect = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: fRadius, height: fRadius))
        return rect
    }
    
    override func setToAnimation(contextTransition: UIViewControllerContextTransitioning) {
        //获取目标动画的VC
        guard let toVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }
        let containView = contextTransition.containerView
        let center = toVC.view.center
        let rect = frameToCircle(centerPoint: centerPoint, size: toVC.view.bounds.size)
        let backView = UIView.init(frame: rect)
        backView.backgroundColor = UIColor.orange
        backView.center = centerPoint
        backView.layer.cornerRadius = backView.frame.height/2
        backView.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
        containView.addSubview(backView)
        self.startView = backView
        toVC.view.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
        toVC.view.alpha = 0
        toVC.view.center = centerPoint
        containView.addSubview(toVC.view)
        
        UIView.animate(withDuration: duration, animations: {
            backView.transform = CGAffineTransform.identity
            toVC.view.center = center
            toVC.view.transform = CGAffineTransform.identity
            toVC.view.alpha = 1
        }) { (finished) in
            contextTransition.completeTransition(!contextTransition.transitionWasCancelled)
        }
    }
    
    override func setBackAnimation(contextTransition: UIViewControllerContextTransitioning) {
        //获取目标动画的VC
        guard let fromVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }
        let containView = contextTransition.containerView
        containView.insertSubview(toVC.view, at: 0)
        weak var weakself = self
        UIView.animate(withDuration: duration, animations: {
            // 缩小
            weakself?.startView?.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
            fromVC.view.center = weakself?.centerPoint ?? CGPoint.zero
            fromVC.view.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
            fromVC.view.alpha = 0
        }) { (fin) in
            contextTransition.completeTransition(!contextTransition.transitionWasCancelled)
            weakself?.startView?.removeFromSuperview()
        }
    }
}


// MARK:--- demo
/*
 fromVC:
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 view.backgroundColor = UIColor.white
 
 let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 60))
 button.center = view.center
 button.layer.cornerRadius = 30
 button.addTarget(self, action: #selector(buttonAction(btn:)), for: .touchUpInside)
 button.setImage(UIImage.init(named: "add"), for: .normal)
 button.adjustsImageWhenHighlighted = false
 view.addSubview(button)
 
 }
 
 @objc func buttonAction(btn:UIButton) {
 let doorvc = CircleRectSpreadToViewController.init()
 let manage = ModalWithCircleFrameSpread.init(startPoint: btn.center)
 sk_presentViewControler(viewController: doorvc, animation: manage)
 }
 
 
 toVC:
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 view.backgroundColor = UIColor.blue
 
 let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 60))
 button.center = view.center
 button.layer.cornerRadius = 30
 button.addTarget(self, action: #selector(buttonAction(btn:)), for: .touchUpInside)
 button.setImage(UIImage.init(named: "cha"), for: .normal)
 button.adjustsImageWhenHighlighted = false
 view.addSubview(button)
 
 let label = UILabel.init(frame: CGRect.init(x: 0, y: 150, width: view.frame.width, height: 50))
 label.font = UIFont.systemFont(ofSize: 40)
 label.textColor = UIColor.white
 label.textAlignment = .center
 label.text = "Hello World!"
 view.addSubview(label)
 }
 
 @objc func buttonAction(btn:UIButton) {
 dismiss(animated: true, completion: nil)
 }
 
 */
