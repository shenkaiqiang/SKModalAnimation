//
//  ModalWithOpenDoor.swift
//  shen
//
//  Created by 沈凯强 on 2021/01/01.
//  Copyright © 2021 mn. All rights reserved.
//

import UIKit
/// 开门的效果
class ModalWithOpenDoor: ModalAnimationManager {
    override func setToAnimation(contextTransition: UIViewControllerContextTransitioning) {
        //获取目标动画的VC
        guard let fromVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromView = fromVC.view, let toView = toVC.view else {
                return
        }
        let containerView = contextTransition.containerView
        //截图
        let fromHalfLeftRect = CGRect.init(x: 0, y: 0, width: fromView.frame.width/2, height: fromView.frame.height)
        let fromHalfRightRect = CGRect.init(x: fromView.frame.width/2, y: 0, width: fromView.frame.width/2, height: fromView.frame.height)
        guard let toSnapView = toView.snapshotView(afterScreenUpdates: true),
            let fromHalfLeftSnapView = fromView.resizableSnapshotView(from: fromHalfLeftRect, afterScreenUpdates: false, withCapInsets: UIEdgeInsets.zero),
            let fromHalfRightSnapView = fromView.resizableSnapshotView(from: fromHalfRightRect, afterScreenUpdates: false, withCapInsets: UIEdgeInsets.zero) else {
                return
        }
        
        toSnapView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1)
        fromHalfLeftSnapView.frame = fromHalfLeftRect
        fromHalfRightSnapView.frame = fromHalfRightRect
        
        //将截图添加到 containerView 上
        containerView.addSubview(fromHalfLeftSnapView)
        containerView.addSubview(fromHalfRightSnapView)
        containerView.addSubview(toSnapView)
        fromView.isHidden = true
        
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            // 左移
            fromHalfLeftSnapView.frame = fromHalfLeftSnapView.frame.offsetBy(dx: -fromHalfLeftSnapView.frame.width, dy: 0)
            // 右移
            fromHalfRightSnapView.frame = fromHalfRightSnapView.frame.offsetBy(dx: fromHalfRightSnapView.frame.width, dy: 0)
            toSnapView.layer.transform = CATransform3DIdentity
        }) { (finished) in
            fromView.isHidden = false
            fromHalfLeftSnapView.removeFromSuperview()
            fromHalfRightSnapView.removeFromSuperview()
            toSnapView.removeFromSuperview()
            if contextTransition.transitionWasCancelled {
                containerView.addSubview(fromView)
            } else {
                containerView.addSubview(toView)
            }
            contextTransition.completeTransition(!contextTransition.transitionWasCancelled)
        }
    }
    override func setBackAnimation(contextTransition: UIViewControllerContextTransitioning) {
        //获取目标动画的VC
        guard let fromVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromView = fromVC.view, let toView = toVC.view else {
                return
        }
        let containerView = contextTransition.containerView
        //截图
        let toHalfLeftRect = CGRect.init(x: 0, y: 0, width: toView.frame.width/2, height: toView.frame.height)
        let toHalfRightRect = CGRect.init(x: toView.frame.width/2, y: 0, width: toView.frame.width/2, height: toView.frame.height)
        guard let fromSnapView = fromView.snapshotView(afterScreenUpdates: true),
            let toHalfLeftSnapView = toView.resizableSnapshotView(from: toHalfLeftRect, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero),
            let toHalfRightSnapView = toView.resizableSnapshotView(from: toHalfRightRect, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero) else {
                return
        }
        
        fromSnapView.layer.transform = CATransform3DIdentity
        toHalfLeftSnapView.frame = toHalfLeftRect.offsetBy(dx: -toHalfLeftRect.width, dy: 0)
        toHalfRightSnapView.frame = toHalfRightRect.offsetBy(dx: toHalfRightRect.width, dy: 0)
        
        //将截图添加到 containerView 上
        containerView.addSubview(fromSnapView)
        containerView.addSubview(toHalfLeftSnapView)
        containerView.addSubview(toHalfRightSnapView)
        fromView.isHidden = true
        
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            // 右移
            toHalfLeftSnapView.frame = toHalfLeftSnapView.frame.offsetBy(dx: toHalfLeftSnapView.frame.width, dy: 0)
            // 左移
            toHalfRightSnapView.frame = toHalfRightSnapView.frame.offsetBy(dx: -toHalfRightSnapView.frame.width, dy: 0)
            fromSnapView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1)
        }) { (finished) in
            fromView.isHidden = false
            fromView.removeFromSuperview()
            fromSnapView.removeFromSuperview()
            toHalfLeftSnapView.removeFromSuperview()
            toHalfRightSnapView.removeFromSuperview()
            if contextTransition.transitionWasCancelled {
                containerView.addSubview(fromView)
            } else {
                containerView.addSubview(toView)
            }
            contextTransition.completeTransition(!contextTransition.transitionWasCancelled)
        }
    }
}

// MARK:--- demo
/*
 fromVC:
 
 override func viewDidLoad() {
 super.viewDidLoad()
 view.layer.contents = UIImage.init(named: "11.jpg")?.cgImage
 
 let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 60))
 button.center = view.center
 button.layer.cornerRadius = 30
 button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
 button.setImage(UIImage.init(named: "circle"), for: .normal)
 button.adjustsImageWhenHighlighted = false
 view.addSubview(button)
 
 }
 
 @objc func buttonAction() {
 let doorvc = OpenDoorToViewController.init()
 let manage = ModalWithOpenDoor.init()
 sk_presentViewControler(viewController: doorvc, animation: manage)
 }

 
 toVC:
 
 override func viewDidLoad() {
 super.viewDidLoad()
 view.layer.contents = UIImage.init(named: "00.jpg")?.cgImage
 weak var weakself = self
 sk_registerBackGestureInteractiveTransition(direction: .left) {
 weakself?.dismiss(animated: true, completion: nil)
 }
 }
 
 */
