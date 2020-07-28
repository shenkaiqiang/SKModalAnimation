//
//  ModalWithMiddlePage.swift
//  shen
//
//  Created by 沈凯强 on 2021/01/01.
//  Copyright © 2021 mn. All rights reserved.
//

import UIKit
/// 翻页的效果
class ModalWithMiddlePage: ModalAnimationManager {
    
    func addShadowView(view:UIView, startPoint:CGPoint, endPoint:CGPoint) -> UIView {
        let shadow = UIView.init(frame: view.bounds)
        view.addSubview(shadow)
        //颜色可以渐变
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.frame = shadow.bounds
        shadow.layer.addSublayer(gradientLayer)
        gradientLayer.colors = [UIColor.init(white: 0, alpha: 0.1).cgColor, UIColor.init(white: 0, alpha: 0).cgColor]
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        return shadow
    }

    override func setToAnimation(contextTransition: UIViewControllerContextTransitioning) {
        //获取目标动画的VC
        guard let fromVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        let containerView = contextTransition.containerView
        //m34 这个参数有点不好理解  为透视效果 我在http://www.jianshu.com/p/e8d1985dccec这里有讲
        //当Z轴上有变化的时候 我们所看到的透视效果 可以对比看看 当你改成-0.1的时候 就懂了
        var transform = CATransform3DIdentity
        transform.m34 = -0.002
        containerView.layer.sublayerTransform = transform
        //截图
        //当前页面的右侧
        let fromHalfRightRect = CGRect.init(x: fromVC.view.frame.width/2, y: 0, width: fromVC.view.frame.width/2, height: fromVC.view.frame.height)
        //目标页面的左侧
        let toHalfLeftRect = CGRect.init(x: 0, y: 0, width: toVC.view.frame.width/2, height: toVC.view.frame.height)
        //目标页面的右侧
        let toHalfRightRect = CGRect.init(x: toVC.view.frame.width/2, y: 0, width: toVC.view.frame.width/2, height: toVC.view.frame.height)

        //截三张图 当前页面的右侧 目标页面的左和右
        guard let fromHalfRightSnapView = fromVC.view.resizableSnapshotView(from: fromHalfRightRect, afterScreenUpdates: false, withCapInsets: UIEdgeInsets.zero),
            let toHalfLeftSnapView = toVC.view.resizableSnapshotView(from: toHalfLeftRect, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero),
            let toHalfRightSnapView = toVC.view.resizableSnapshotView(from: toHalfRightRect, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero) else {
                return
        }
        
        fromHalfRightSnapView.frame = fromHalfRightRect
        toHalfLeftSnapView.frame = toHalfLeftRect
        toHalfRightSnapView.frame = toHalfRightRect
        //重新设置anchorPoint  分别绕自己的最左和最右旋转
        fromHalfRightSnapView.layer.position = CGPoint.init(x: fromHalfRightSnapView.frame.minX, y: fromHalfRightSnapView.frame.minY+fromHalfRightSnapView.frame.height/2)
        fromHalfRightSnapView.layer.anchorPoint = CGPoint.init(x: 0, y: 0.5)
        toHalfLeftSnapView.layer.position = CGPoint.init(x: toHalfLeftSnapView.frame.minX+toHalfLeftSnapView.frame.width, y: toHalfLeftSnapView.frame.minY+toHalfLeftSnapView.frame.height/2)
        toHalfLeftSnapView.layer.anchorPoint = CGPoint.init(x: 1, y: 0.5)
        
        //添加阴影效果
        let fromHalfRightShadowView = addShadowView(view: fromHalfRightSnapView, startPoint: CGPoint.init(x: 0, y: 1), endPoint: CGPoint.init(x: 1, y: 1))
        let toHalfLeftShdowView = addShadowView(view: toHalfLeftSnapView, startPoint: CGPoint.init(x: 1, y: 1), endPoint: CGPoint.init(x: 0, y: 1))
        //添加视图  注意顺序
        containerView.insertSubview(toVC.view, at: 0)
        containerView.addSubview(toHalfLeftSnapView)
        containerView.addSubview(toHalfRightSnapView)
        containerView.addSubview(fromHalfRightSnapView)
        
        toHalfLeftSnapView.isHidden = true
        
        //先旋转到最中间的位置
        toHalfLeftSnapView.layer.transform = CATransform3DMakeRotation(CGFloat.pi/2, 0, 1, 0)
        //StartTime 和 relativeDuration 均为百分百
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: UIView.KeyframeAnimationOptions.calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: self.duration/2, animations: {
                fromHalfRightSnapView.layer.transform = CATransform3DMakeRotation(-CGFloat.pi/2, 0, 1, 0)
                fromHalfRightShadowView.alpha = 1
            })
            UIView.addKeyframe(withRelativeStartTime: self.duration/2, relativeDuration: self.duration/2, animations: {
                toHalfLeftSnapView.isHidden = false
                toHalfLeftSnapView.layer.transform = CATransform3DIdentity
                toHalfLeftShdowView.alpha = 0
            })
        }) { (finished) in
            toHalfLeftSnapView.removeFromSuperview()
            toHalfRightSnapView.removeFromSuperview()
            fromHalfRightSnapView.removeFromSuperview()
            fromVC.view.removeFromSuperview()
            
            if contextTransition.transitionWasCancelled {
                containerView.addSubview(fromVC.view)
            }
            contextTransition.completeTransition(!contextTransition.transitionWasCancelled)
        }
        /*
         //本来打算用基础动画来实现 但是由于需要保存几个变量 在动画完成的代理函数中用，所以就取消这个想法了
         //    CABasicAnimation *fromRightAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
         //    fromRightAnimation.duration = self.duration/2.0;
         //    fromRightAnimation.beginTime = CACurrentMediaTime();
         //    fromRightAnimation.toValue = @(-M_PI_2);
         //    [fromRightSnapView.layer addAnimation:fromRightAnimation forKey:nil];
         //
         //
         //    CABasicAnimation *toLeftAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
         //    toLeftAnimation.beginTime = CACurrentMediaTime() + self.duration/2.0;
         //    toLeftAnimation.fromValue = @(M_PI_2);
         //    [toLeftAnimation setValue:contextTransition forKey:@"contextTransition"];
         //    [toLeftSnapView.layer addAnimation:toLeftAnimation forKey:@"toLeftAnimation"];
         */
    }
    override func setBackAnimation(contextTransition: UIViewControllerContextTransitioning) {
        //获取目标动画的VC
        guard let fromVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        let containerView = contextTransition.containerView
        //m34 这个参数有点不好理解  为透视效果 我在http://www.jianshu.com/p/e8d1985dccec这里有讲
        //当Z轴上有变化的时候 我们所看到的透视效果 可以对比看看 当你改成-0.1的时候 就懂了
        var transform = CATransform3DIdentity
        transform.m34 = -0.002
        containerView.layer.sublayerTransform = transform
        
        //截图
        //当前页面的左侧
        let fromHalfLeftRect = CGRect.init(x: 0, y: 0, width: fromVC.view.frame.width/2, height: fromVC.view.frame.height)
        //目标页面的左侧
        let toHalfLeftRect = CGRect.init(x: 0, y: 0, width: toVC.view.frame.width/2, height: toVC.view.frame.height)
        //目标页面的右侧
        let toHalfRightRect = CGRect.init(x: toVC.view.frame.width/2, y: 0, width: toVC.view.frame.width/2, height: toVC.view.frame.height)
        
        //截三张图 当前页面的左侧 目标页面的左和右
        guard let fromHalfLeftSnapView = fromVC.view.resizableSnapshotView(from: fromHalfLeftRect, afterScreenUpdates: false, withCapInsets: UIEdgeInsets.zero),
            let toHalfLeftSnapView = toVC.view.resizableSnapshotView(from: toHalfLeftRect, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero),
            let toHalfRightSnapView = toVC.view.resizableSnapshotView(from: toHalfRightRect, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero) else {
                return
        }

        fromHalfLeftSnapView.frame = fromHalfLeftRect
        toHalfLeftSnapView.frame = toHalfLeftRect
        toHalfRightSnapView.frame = toHalfRightRect
        //重新设置anchorPoint  分别绕自己的最左和最右旋转
        fromHalfLeftSnapView.layer.position = CGPoint.init(x: fromHalfLeftSnapView.frame.minX + fromHalfLeftSnapView.frame.width, y: fromHalfLeftSnapView.frame.minY+fromHalfLeftSnapView.frame.height/2)
        fromHalfLeftSnapView.layer.anchorPoint = CGPoint.init(x: 1, y: 0.5)
        toHalfRightSnapView.layer.position = CGPoint.init(x: toHalfRightSnapView.frame.minX, y: toHalfRightSnapView.frame.minY+toHalfRightSnapView.frame.height/2)
        toHalfRightSnapView.layer.anchorPoint = CGPoint.init(x: 0, y: 0.5)
        
        //添加阴影效果
        let fromHalfLeftShadowView = addShadowView(view: fromHalfLeftSnapView, startPoint: CGPoint.init(x: 1, y: 1), endPoint: CGPoint.init(x: 0, y: 1))
        let toHalfRightShdowView = addShadowView(view: toHalfRightSnapView, startPoint: CGPoint.init(x: 0, y: 1), endPoint: CGPoint.init(x: 1, y: 1))
        //添加视图  注意顺序
        containerView.insertSubview(toVC.view, at: 0)
        containerView.addSubview(toHalfLeftSnapView)
        containerView.addSubview(toHalfRightSnapView)
        containerView.addSubview(fromHalfLeftSnapView)
        
        toHalfRightSnapView.isHidden = true
        
        //先旋转到最中间的位置
        toHalfRightSnapView.layer.transform = CATransform3DMakeRotation(-CGFloat.pi/2, 0, 1, 0)
        //StartTime 和 relativeDuration 均为百分百
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: UIView.KeyframeAnimationOptions.calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: self.duration/2, animations: {
                fromHalfLeftSnapView.layer.transform = CATransform3DMakeRotation(CGFloat.pi/2, 0, 1, 0)
                fromHalfLeftShadowView.alpha = 1
            })
            UIView.addKeyframe(withRelativeStartTime: self.duration/2, relativeDuration: self.duration/2, animations: {
                toHalfRightSnapView.isHidden = false
                toHalfRightSnapView.layer.transform = CATransform3DIdentity
                toHalfRightShdowView.alpha = 0
            })
        }) { (finished) in
            toHalfLeftSnapView.removeFromSuperview()
            toHalfRightSnapView.removeFromSuperview()
            fromHalfLeftSnapView.removeFromSuperview()
            fromVC.view.removeFromSuperview()
            
            if contextTransition.transitionWasCancelled {
                containerView.addSubview(fromVC.view)
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
 view.backgroundColor = UIColor.white
 view.layer.contents = UIImage.init(named: "b.jpg")?.cgImage
 navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "tttt", style: .done, target: self, action: #selector(testAction))
 
 weak var weakself = self
 sk_registerToGestureInteractiveTransition(direction: .right) {
 let pagevc = MiddlePageToViewController.init()
 let manager = ModalWithMiddlePage.init()
 manager.duration = 1
 weakself?.sk_pushViewController(viewController: pagevc, animation: manager)
 }
 }
 
 @objc func testAction() {
 let pagevc = MiddlePageToViewController.init()
 let manager = ModalWithMiddlePage.init()
 manager.duration = 1
 sk_pushViewController(viewController: pagevc, animation: manager)
 }
 
 
 toVC:
 
 override func viewDidLoad() {
 super.viewDidLoad()
 view.layer.contents = UIImage.init(named: "00.jpg")?.cgImage
 weak var weakself = self
 sk_registerBackGestureInteractiveTransition(direction: .left) {
 weakself?.navigationController?.popViewController(animated: true)
 }
 }
 
 */
