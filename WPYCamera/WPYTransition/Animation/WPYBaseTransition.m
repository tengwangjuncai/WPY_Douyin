//
//  WPYBaseTransition.m
//  WPYCamera
//
//  Created by 王鹏宇 on 5/27/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import "WPYBaseTransition.h"

@implementation WPYBaseTransition


+ (instancetype)transitionManager{
    
    return [[self alloc] init];
}




#pragma mark -- UIViewControllerAnimatedTransitioning

//转场时间

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    if (self.transitionTime > 0) {
        
        return self.transitionTime;
    }
    
    //没设置转场时间  默认系统转场时间
    return  UINavigationControllerHideShowBarDuration;
}


//动画转场

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    //获取转场容器
    UIView * containnerView = [transitionContext containerView];
    
    //获取转场控制器
    UIViewController * fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController * toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    self.containerView = containnerView;
    self.fromVC = fromVC;
    self.toVC = toVC;
    self.transitionContext = transitionContext;
    
    [self animateTransition];
}


//子类重写

-(void)animateTransition{
    
}

-(void)completeTransition{
    
    [self.transitionContext completeTransition:!self.transitionContext.transitionWasCancelled];
}
@end
