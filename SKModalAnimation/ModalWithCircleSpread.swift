//
//  ModalWithCircleSpread.swift
//  shen
//
//  Created by 沈凯强 on 2021/01/01.
//  Copyright © 2021 mn. All rights reserved.
//

import UIKit

class ModalWithCircleSpread: ModalAnimationManager {
    
    private let animationKey = "pathContextTransition"
    //动画的中心坐标
    private var centerPoint = CGPoint.zero
    //半径
    private var radius:CGFloat = 0
    //保存layer在动画结束的时候 可以根据这个来获取添加的动画
    private var maskShapeLayer:CAShapeLayer?
    //保存转场动画开始时的路径 当退出动画取消的时候 保存原来的样子
    private var startPath:UIBezierPath?

    /**
     初始化方法
     
     @param point 扩散的中心位置
     @param radius 半径
     @return 返回
     */
    convenience init(startPoint:CGPoint, radius:CGFloat) {
        self.init()
        self.centerPoint = startPoint
        self.radius = radius
    }
    private override init() {
        super.init()
    }
    override func setToAnimation(contextTransition: UIViewControllerContextTransitioning) {
        //获取目标动画的VC
        guard let toVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }
        let containerView = contextTransition.containerView
        containerView.addSubview(toVC.view)
        //创建UIBezierPath路径 作为后面动画的起始路径
        let startPath = UIBezierPath.init(arcCenter: centerPoint, radius: radius, startAngle: 0, endAngle: CGFloat.pi*2, clockwise: true)
        //创建结束UIBezierPath
        //首先我们需要得到后面路径的半径  半径应该是距四个角最远的距离
        let xx = centerPoint.x
        let yy = centerPoint.y
        //取出其中距屏幕最远的距离 来求围城矩形的对角线 即我们所需要的半径
        let radiusX = CGFloat.maximum(xx, containerView.frame.width-xx)
        let radiusY = CGFloat.maximum(yy, containerView.frame.width-yy)
        //通过勾股定理算出半径
        let endRadius = sqrtf(powf(Float(radiusX), 2)+powf(Float(radiusY), 2))
        let endPath = UIBezierPath.init(arcCenter: centerPoint, radius: CGFloat(endRadius), startAngle: 0, endAngle: CGFloat.pi*2, clockwise: true)
        //创建CAShapeLayer 用于后面的动画
        let shapeL = CAShapeLayer.init()
        shapeL.path = endPath.cgPath
        toVC.view.layer.mask = shapeL
        let animation = CABasicAnimation.init(keyPath: "path")
        animation.fromValue = startPath.cgPath
        animation.duration = duration
        animation.delegate = self
        //保存contextTransition  后面动画结束的时候调用
        animation.setValue(contextTransition, forKey: animationKey)
        shapeL.add(animation, forKey: nil)
        maskShapeLayer = shapeL
    }
    
    override func setBackAnimation(contextTransition: UIViewControllerContextTransitioning) {
        //将tovc的view放到最下面一层
        guard let fromVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = contextTransition.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }
        let containView = contextTransition.containerView
        containView.insertSubview(toVC.view, at: 0)
        //push前的 startPath 作为endPath
        let endPath = UIBezierPath.init(arcCenter: centerPoint, radius: radius, startAngle: 0, endAngle: CGFloat.pi*2, clockwise: true)
        let shapL = fromVC.view.layer.mask as? CAShapeLayer
        self.maskShapeLayer = shapL
        //将pop后的 path作为startPath
        guard let pp = shapL?.path else {
            return
        }
        let startPath = UIBezierPath.init(cgPath: pp)
        self.startPath = startPath
        shapL?.path = endPath.cgPath
        let animation = CABasicAnimation.init(keyPath: "path")
        animation.fromValue = startPath.cgPath
        animation.toValue = endPath.cgPath
        animation.duration = duration
        animation.delegate = self
        //保存contextTransition  后面动画结束的时候调用
        animation.setValue(contextTransition, forKey: animationKey)
        shapL?.add(animation, forKey: nil)
    }
}

extension ModalWithCircleSpread: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let contextTransition = anim.value(forKey: animationKey) as? UIViewControllerContextTransitioning else {
            return
        }
        //取消的时候 将动画还原到之前的路径
        if contextTransition.transitionWasCancelled {
            maskShapeLayer?.path = startPath?.cgPath
        }
        // 声明过渡结束
        contextTransition.completeTransition(!contextTransition.transitionWasCancelled)
    }
}
// MARK:--- demo
/*
 fromVC:
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 view.layer.contents = UIImage.init(named: "4.jpg")?.cgImage
 
 let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 60))
 button.center = view.center
 button.layer.cornerRadius = 30
 button.addTarget(self, action: #selector(buttonAction(btn:)), for: .touchUpInside)
 button.setImage(UIImage.init(named: "add"), for: .normal)
 button.adjustsImageWhenHighlighted = false
 view.addSubview(button)
 
 }
 
 @objc func buttonAction(btn:UIButton) {
 let doorvc = CircleSpreadToController.init()
 let manage = ModalWithCircleSpread.init(startPoint: btn.center, radius: 30)
 sk_pushViewController(viewController: doorvc, animation: manage)
 }
 
 toVC:
 
 override func viewDidLoad() {
 super.viewDidLoad()
 view.layer.contents = UIImage.init(named: "12")?.cgImage
 weak var weakself = self
 sk_registerBackGestureInteractiveTransition(direction: .left) {
 weakself?.navigationController?.popViewController(animated: true)
 }
 }
 */
