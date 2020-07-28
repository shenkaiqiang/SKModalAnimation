//
//  UIViewController+Transition.swift
//  shen
//
//  Created by 沈凯强 on 2021/01/01.
//  Copyright © 2021 mn. All rights reserved.
//

import UIKit

extension UIViewController {
    // 此处要用 var 定义,不能用let,要不没法使用 &
    private struct AssociatedKeys {
        static var kAnimationKey = "kAnimationKey"
        static var kToAnimationKey = "kToAnimationKey"
        static var kToInteractiveTransition = "toInteractiveTransition"
    }
    
    /**
     push动画
     
     @param viewController 被push viewController
     @param ModalAnimationManager 控制类
     */
    public func sk_pushViewController(viewController:UIViewController, animation:ModalAnimationManager) {
        guard let navi = navigationController else {
            return
        }
        navi.delegate = animation
        let object = objc_getAssociatedObject(self,&AssociatedKeys.kToAnimationKey)
        if let toGesture = object as? GestureInteractiveManager {
            animation.setValue(toGesture, forKey: "toGestureTransition")//
        } 
        objc_setAssociatedObject(viewController, &AssociatedKeys.kAnimationKey, animation, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        navigationController?.pushViewController(viewController, animated: true)
    }
    /**
     present动画
     
     @param viewController 被present viewController
     @param ModalAnimationManager 控制类
     */
    public func sk_presentViewControler(viewController:UIViewController, animation:ModalAnimationManager) {
        //present 动画代理 被执行动画的vc设置代理
        viewController.transitioningDelegate = animation
        if let toInteractiveTransition = objc_getAssociatedObject(self, &AssociatedKeys.kToAnimationKey) as? GestureInteractiveManager {
            animation.setValue(toInteractiveTransition, forKey: "toGestureTransition")
        }
        objc_setAssociatedObject(viewController, &AssociatedKeys.kAnimationKey, animation, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        present(viewController, animated: true, completion: nil)
    }
    /**
     注册入场手势
     direction 方向,边缘触发
     blcok 手势转场触发的点击事件
     */
    public func sk_registerToEdgeGestureTransition(in gestureView:UIView, direction:GestureInteractiveManager.EdgePanGestureDirection, eventClosure:@escaping (()->Void)) {
        let transition = GestureInteractiveManager.init()
        transition.eventClosure = eventClosure
        transition.addEdgePageGesture(in: gestureView, direction: direction)
        objc_setAssociatedObject(self, &AssociatedKeys.kToAnimationKey, transition, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    /**
     注册返回手势
     direction 侧滑方向,边缘触发
     blcok 手势转场触发的点击事件
     */
    public func sk_registerBackEdgeGestureTransition(in gestureView:UIView, direction:GestureInteractiveManager.EdgePanGestureDirection, eventClosure:@escaping (()->Void)) {
        let transition = GestureInteractiveManager.init()
        transition.eventClosure = eventClosure
        transition.addEdgePageGesture(in: gestureView, direction: direction)
        //判读是否需要返回 然后添加侧滑
        if let manager = objc_getAssociatedObject(self, &AssociatedKeys.kAnimationKey) as? ModalAnimationManager {
            //用kvc的模式  给 animator的backInteractiveTransition 退场赋值
            manager.setValue(transition, forKey: "backGestureTransition")
        }
    }
    
    /**
     注册入场平移手势
     direction 方向
     blcok 手势转场触发的点击事件
     */
    public func sk_registerToPanGestureTransition(in gestureView:UIView, direction:GestureInteractiveManager.PanGestureDirection, eventClosure:@escaping (()->Void)) {
        let transition = GestureInteractiveManager.init()
        transition.eventClosure = eventClosure
        transition.addPanGesture(in: gestureView, direction: direction)
        objc_setAssociatedObject(self, &AssociatedKeys.kToAnimationKey, transition, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    /**
     注册返回平移手势
     direction 侧滑方向
     blcok 手势转场触发的点击事件
     */
    public func sk_registerBackPanGestureTransition(in gestureView:UIView, direction:GestureInteractiveManager.PanGestureDirection, eventClosure:@escaping (()->Void)) {
        let transition = GestureInteractiveManager.init()
        transition.eventClosure = eventClosure
        transition.addPanGesture(in: gestureView, direction: direction)
        //判读是否需要返回 然后添加侧滑
        if let manager = objc_getAssociatedObject(self, &AssociatedKeys.kAnimationKey) as? ModalAnimationManager {
            //用kvc的模式  给 animator的backInteractiveTransition 退场赋值
            manager.setValue(transition, forKey: "backGestureTransition")
        }
    }
}
