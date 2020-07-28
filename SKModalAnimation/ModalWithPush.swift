//
//  ModalWithPush.swift
//  shen
//
//  Created by 沈凯强 on 2021/01/01.
//  Copyright © 2021 mn. All rights reserved.
//

import UIKit
/// push 效果
class ModalWithPush: ModalAnimationManager {
    override func setToAnimation(contextTransition: UIViewControllerContextTransitioning) {
        //获取目标动画的VC
        guard let fromVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        let containerView = contextTransition.containerView
        let screenWidth = UIScreen.main.bounds.width
        
        fromVC.view.frame.origin.x = 0
        containerView.addSubview(toVC.view)
        
        toVC.view.frame.origin.x = screenWidth
        
        
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            // 左移
            fromVC.view.frame.origin.x = -screenWidth
            toVC.view.frame.origin.x = 0
        }) { (finished) in
            fromVC.view.removeFromSuperview()
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
        let screenWidth = UIScreen.main.bounds.width
        
        fromVC.view.frame.origin.x = 0
        containerView.addSubview(toVC.view)
        toVC.view.frame.origin.x = -screenWidth
        
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            // 右移
            fromVC.view.frame.origin.x = screenWidth
            toVC.view.frame.origin.x = 0
        }) { (finished) in
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
