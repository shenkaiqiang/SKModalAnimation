//
//  ModalWithSlide.swift
//  shen
//
//  Created by 沈凯强 on 2021/01/01.
//  Copyright © 2021 mn. All rights reserved.
//

import UIKit
/// 上下方向的 push 效果
class ModalWithSlide: ModalAnimationManager {
    override func setToAnimation(contextTransition: UIViewControllerContextTransitioning) {
        //获取目标动画的VC
        guard let fromVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        let containerView = contextTransition.containerView
        //截图
        guard let toSnapView = toVC.view.snapshotView(afterScreenUpdates: true),
            let fromSnapView = fromVC.view.snapshotView(afterScreenUpdates: false) else {
                return
        }
        toSnapView.frame = CGRect.init(x: 0, y: -toSnapView.frame.height, width: toSnapView.frame.width, height: toSnapView.frame.height)
        //将截图添加到 containerView 上
        containerView.addSubview(fromSnapView)
        containerView.addSubview(toSnapView)
        fromVC.view.isHidden = true
        
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            // 下移
            fromSnapView.frame = fromSnapView.frame.offsetBy(dx: 0, dy: fromSnapView.frame.height)
            toSnapView.frame = toSnapView.frame.offsetBy(dx: 0, dy: toSnapView.frame.height)
        }) { (finished) in
            fromVC.view.isHidden = false
            fromSnapView.removeFromSuperview()
            toSnapView.removeFromSuperview()
            if contextTransition.transitionWasCancelled {
                containerView.addSubview(fromVC.view)
            } else {
                containerView.addSubview(toVC.view)
            }
            contextTransition.completeTransition(!contextTransition.transitionWasCancelled)
        }
    }
    override func setBackAnimation(contextTransition: UIViewControllerContextTransitioning) {
        //获取目标动画的VC
        guard let fromVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        let containerView = contextTransition.containerView
        //截图
        guard let fromSnapView = fromVC.view.snapshotView(afterScreenUpdates: true),
            let toSnapView = toVC.view.snapshotView(afterScreenUpdates: true) else {
                return
        }
        toSnapView.frame = CGRect.init(x: 0, y: fromSnapView.frame.height, width: toSnapView.frame.width, height: toSnapView.frame.height)
        
        //将截图添加到 containerView 上
        containerView.addSubview(fromSnapView)
        containerView.addSubview(toSnapView)
        fromVC.view.isHidden = true
        
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            // 上移
            toSnapView.frame = toSnapView.frame.offsetBy(dx: 0, dy: -toSnapView.frame.height)
            fromSnapView.frame = fromSnapView.frame.offsetBy(dx: 0, dy: -fromSnapView.frame.height)
        }) { (finished) in
            fromVC.view.isHidden = false
            fromVC.view.removeFromSuperview()
            fromSnapView.removeFromSuperview()
            toSnapView.removeFromSuperview()
            if contextTransition.transitionWasCancelled {
                containerView.addSubview(fromVC.view)
            } else {
                containerView.addSubview(toVC.view)
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
