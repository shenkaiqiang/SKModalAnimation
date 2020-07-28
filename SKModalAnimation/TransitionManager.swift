//
//  ModalAnimationManager.swift
//  shen
//
//  Created by 沈凯强 on 2021/01/01.
//  Copyright © 2021 mn. All rights reserved.
//

import UIKit
/// 综合管理转场动画的类,作用：主要是管理转场需要的一些设置，诸如转场时间和转场的实现（主要是在子类中进行实现，分离开来），用户在自定义转场动画的时候，只需要继承该类并重写父类方法就可以
public class ModalAnimationManager: NSObject {
    
    /// 转场动画的时间 
    var duration:TimeInterval = 0.3
    
    /// 入场动画
    func setToAnimation(contextTransition:UIViewControllerContextTransitioning) {
        //需在子类中进行重写
    }
    
    /// 退场动画
    func setBackAnimation(contextTransition:UIViewControllerContextTransitioning) {
        //需在子类中进行重写
    }
    
    // 入场动画
    private lazy var toTransitionAnimation:TransitionAnimationConfigure = {
        weak var weakself = self
        let animation = TransitionAnimationConfigure.init(duration: duration)
        animation.animationClosure = { contextTransition in
            weakself?.setToAnimation(contextTransition: contextTransition)
        }
        return animation
    }()
    
    // 退场动画
    private lazy var backTransitionAnimation:TransitionAnimationConfigure = {
        weak var weakself = self
        let animation = TransitionAnimationConfigure.init(duration: duration)
        animation.animationClosure = { contextTransition in
            weakself?.setBackAnimation(contextTransition: contextTransition)
        }
        return animation
    }()
    //入场手势
    @objc private var toGestureTransition:GestureInteractiveManager?
    //退场手势
    @objc private var backGestureTransition:GestureInteractiveManager?
    //转场类型 push or pop
    private var operation = UINavigationController.Operation.push

}
extension ModalAnimationManager:UINavigationControllerDelegate,UIViewControllerTransitioningDelegate {
    // UIViewControllerTransitioningDelegate
    //非手势转场交互 for present
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return toTransitionAnimation
    }
    //非手势转场交互 for dismiss
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return backTransitionAnimation
    }
    
    //手势交互 for dismiss
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (backGestureTransition?.isPanGestureInteration ?? false) ? backGestureTransition : nil
    }
    //手势交互 for present
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (toGestureTransition?.isPanGestureInteration ?? false) ? toGestureTransition : nil
    }
    
    // UINavigationControllerDelegate
    // 非手势转场交互 for push or pop, 注释:通过 fromVC 和 toVC 我们可以在此设置需要自定义动画的类
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.operation = operation
        if operation == .push {
            return toTransitionAnimation
        } else if operation == .pop {
            return backTransitionAnimation
        } else {
            return nil
        }
    }
    //手势交互 for push or pop
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if operation == .push {
            let bbb = (toGestureTransition?.isPanGestureInteration ?? false)
            return bbb ? toGestureTransition : nil
        } else {
            return (backGestureTransition?.isPanGestureInteration ?? false) ? backGestureTransition : nil
        }
    }
}

/// 转场动画配置及实现类,作用：虽然是配置和实现类，但是在该类中并没有进行实现
private class TransitionAnimationConfigure: NSObject,UIViewControllerAnimatedTransitioning {
    
    /// 动画时间
    private var duration:TimeInterval = 0
    /// 将满足UIViewControllerContextTransitioning协议的对象传到管理内 在管理类对动画统一实现
    var animationClosure:((_ contextTransition:UIViewControllerContextTransitioning)->Void)?
    
    /// 初始化方法, duration 转场时间
    convenience init(duration:TimeInterval) {
        self.init()
        self.duration = duration
    }
    
    // 协议方法
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        animationClosure?(transitionContext)
    }
    
}

/// 手势交互管理类,作用：主要通过侧滑手势来管理交互，该类的对象会根据我们的手势，来决定我们的自定义过渡的完成度，所以此次我采用继承的方式，然后在继承的类中加入滑动手势类，这里加入的是侧滑手势类UIScreenEdgePanGestureRecognizer
public class GestureInteractiveManager: UIPercentDrivenInteractiveTransition {
    /// 手势的方向枚举
    public enum EdgePanGestureDirection {
        case left
        case right
        // top bottom ,上下两个方向会滑出手机菜单
    }
    /// 滑动方向
    public enum PanGestureDirection {
        case left // 向左滑
        case right // 向右滑
        case top // 向上滑
        case bottom // 向下滑
    }
    
    /// 保存添加手势的view
    private var gestureView:UIView?
    /// 记录平移手势的设置方向
    private var panDirection = PanGestureDirection.top
    /// 是否满足侧滑手势交互
    var isPanGestureInteration = false
    /// 转场时的操作 不用传参数的 闭包
    var eventClosure:(()->Void)?
    private var progress:CGFloat = 0
    
    /// 添加 平移手势,不需要从屏幕最边上开始
    func addPanGesture(in view:UIView, direction:PanGestureDirection) {
        gestureView = view
        panDirection = direction
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureAction(gesture: )))
        gestureView?.addGestureRecognizer(pan)
    }
    @objc func panGestureAction(gesture:UIPanGestureRecognizer) {
        // 计算用户手指划了多远
        guard let gestureView = gestureView else {
            return
        }
        let point = gesture.translation(in: gestureView)
        
        var offset:CGFloat = 0
        if panDirection == .top || panDirection == .bottom {
            offset = point.y
            progress = abs(point.y) / gestureView.bounds.height
        } else {
            offset = point.x
            progress = abs(point.x) / gestureView.bounds.width

        }
        if offset == 0 {
            return
        }
        // 判断是否向相反方向滑动
        let top = (panDirection == .top) && (offset>0)
        let bottom = (panDirection == .bottom) && (offset < 0)
        let left = (panDirection == .left) && (offset>0)
        let right = (panDirection == .right) && (offset<0)
        if top || bottom || left || right {
            cancel()
            return
        }
        
        let max = CGFloat.maximum(0, progress)
        let minProgress = CGFloat.minimum(1, max)
        switch gesture.state {
        case .began:
            isPanGestureInteration = true
            eventClosure?()
        case .changed:
            // 更新 interactive transition 的进度
            update(minProgress)
        case .ended,.cancelled:
            // 完成或者取消过渡
            if minProgress > 0.1 {
                finish()
            } else {
                cancel()
            }
            isPanGestureInteration = false
            progress = 0
        default:
            break
        }
    }
    /// 添加侧滑手势
    func addEdgePageGesture(in view:UIView, direction:EdgePanGestureDirection) {
        let gesture = UIScreenEdgePanGestureRecognizer.init(target: self, action: #selector(handlePopRecognizer(gesture: )))
        switch direction {
        case .left:
            gesture.edges = .left
        case .right:
            gesture.edges = .right
        }
        gestureView = view
        gestureView?.addGestureRecognizer(gesture)
    }
    
    @objc func handlePopRecognizer(gesture:UIScreenEdgePanGestureRecognizer) {
        // 计算用户手指划了多远
        guard let gestureView = gestureView else {
            return
        }
        let point = gesture.translation(in: gestureView)
        let progress = abs(point.x) / gestureView.bounds.width
        let max = CGFloat.maximum(0, progress)
        let minProgress = CGFloat.minimum(1, max)
        switch gesture.state {
        case .began:
            isPanGestureInteration = true
            eventClosure?()
        case .changed:
            // 更新 interactive transition 的进度
            update(minProgress)
        case .ended,.cancelled:
            // 完成或者取消过渡
            if minProgress > 0.5 {
                finish()
            } else {
                cancel()
            }
            isPanGestureInteration = false
        default:
            break
        }
    }
}
// MARK: --- 思路描述
/*UINavigationControllerDelegate
 
 先来看看其中需要用到的函数
 
 - (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
 interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController ;
 - (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
 animationControllerForOperation:(UINavigationControllerOperation)operation
 fromViewController:(UIViewController *)fromVC
 toViewController:(UIViewController *)toVC ;
 第一个函数的返回值是一个id <UIViewControllerInteractiveTransitioning>值
 第二个函数返回的值是一个id <UIViewControllerAnimatedTransitioning>值
 那么我们就先从这两个返回值入手，来看下两个函数的作用
 
 UIViewControllerInteractiveTransitioning 、UIPercentDrivenInteractiveTransition
 
 这两个类又是干什么的呢？UIPercentDrivenInteractiveTransition遵守协议UIViewControllerInteractiveTransitioning,通过查阅资料了解到，UIPercentDrivenInteractiveTransition这个类的对象会根据我们的手势，来决定我们的自定义过渡的完成度，也就是这两个其实是和手势交互相关联的，自然而然我们就想到了侧滑手势，说到这里，我就顺带介绍一个类，UIScreenEdgePanGestureRecognizer，手势侧滑的类，具体怎么使用，后面我会陆续讲到。
 
 涉及函数
 
 //更新进度
 - (void)updateInteractiveTransition:(CGFloat)percentComplete;
 //取消转场 回到转场前的效果
 - (void)cancelInteractiveTransition;
 //完成转场
 - (void)finishInteractiveTransition;
 UIViewControllerAnimatedTransitioning
 
 在这个类中，我们又看到了两个函数
 
 //转场时间
 - (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext;
 - (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext;
 其中又涉及到一个新的类UIViewControllerContextTransitioning，那么这个又是干什么的呢？我们等下再来了解，先来谈谈第一个函数transitionDuration，从返回值我们可以猜测出这是和时间有关的，没错，这就是我们自定义转场动画所需要的时间
 那么下面我们就来看看UIViewControllerContextTransitioning
 
 UIViewControllerContextTransitioning
 
 这个类就是我们自定义转场动画所需要的核心，即转场动画的上下文，定义了转场时需要的元素，比如在转场过程中所参与的视图控制器和视图的相关属性
 
 //转场动画的容器
 @property(nonatomic, readonly) UIView *containerView;
 //通过对应的`key`可以得到我们需要的`vc`
 - (UIViewController *)viewControllerForKey:(UITransitionContextViewControllerKey)key
 //转场动画完成时候调用，必须调用，否则在进行其他转场没有任何效果
 - (void)completeTransition:(BOOL)didComplete
 看到这里，我们现在再去看UINavigationControllerDelegate中的两个函数和UIViewControllerAnimatedTransitioning中的animateTransition函数，就能完全理解了
 
 //主要用于手势交互转场 for push or pop
 - (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
 interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController ;
 //非手势交互转场 for push or pop
 - (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
 animationControllerForOperation:(UINavigationControllerOperation)operation
 fromViewController:(UIViewController *)fromVC
 toViewController:(UIViewController *)toVC ;
 //实现转场动画 通过transitionContext
 - (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext;
 到此，我们还有一个类没有了解，那就是UIViewControllerTransitioningDelegate有了前面的分析，我们可以很好的理解
 
 UIViewControllerTransitioningDelegate
 
 主要是针对present和dismiss动画的转场
 
 //非手势转场交互 for present
 - (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
 //非手势转场交互 for dismiss
 - (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
 //手势交互 for dismiss
 - (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
 //手势交互 for present
 - (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
 */
