//
//  WPY_NavDelegate.m
//  WPYCamera
//
//  Created by 王鹏宇 on 5/27/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import "WPY_NavDelegate.h"
#import "WPYPushTransition.h"
#import "WPYPopTransition.h"
#import "UINavigationController+WPYTransition.h"
#import "WPYPresentTransition.h"
#import "WPYDismissTransition.h"
@implementation WPY_NavDelegate

//根据类型  返回自定义转场动画
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    

    if (operation == UINavigationControllerOperationPush) {
        
        if (self.type == rightPush) {
            return [WPYPresentTransition transitionManager];
        }else if(self.type == leftPush){
            return [WPYPushTransition transitionManager];
        }
        
    }else if(operation == UINavigationControllerOperationPop){
        
        if (self.type == rightPop) {
            return [WPYPopTransition transitionManager];
        }else if(self.type == leftPop){
            return [WPYDismissTransition transitionManager];
        }
        
    }
    
    
    
    return nil;
}


//根据动画类型 返回转场动画百分比
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController{
    
    
    if ([animationController isKindOfClass:[WPYDismissTransition class]] || [animationController isKindOfClass:[WPYPopTransition class]]) {
        
        NSString * str = [NSString stringWithFormat:@"-------%@",self.popTransition];
        NSLog(@"%@", str);
        return  self.popTransition;
    }else if([animationController isKindOfClass:[WPYPresentTransition class]] || [animationController isKindOfClass:[WPYPushTransition class]]){
        NSString * str = [NSString stringWithFormat:@"-------%@",self.pushTransition];
        NSLog(@"%@", str);
        return  self.pushTransition;
    }
    
    return nil;
}

//添加转场交互手势
-(void)directionPushPanGesture:(UIPanGestureRecognizer *)gesture{
    
    
    //进度
    CGFloat progress = [gesture translationInView:gesture.view].x / gesture.view.bounds.size.width;
    CGPoint translation = [gesture velocityInView:gesture.view];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.isLeft = translation.x < 0? true:false;
    }
    progress = fabs(progress);
    progress = MIN(1.0, MAX(0.0, progress));
    
   
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        if (self.isLeft) {
            
            switch (self.type) {
                case leftPop:
                {
                    self.popTransition = [UIPercentDrivenInteractiveTransition new];
                    [self.naVC popViewControllerAnimated:YES];
                }
                    break;
                case leftPush:
                {
                    self.pushTransition = [UIPercentDrivenInteractiveTransition new];
                    self.pushTransition.completionCurve = UIViewAnimationCurveEaseOut;
                    [self.pushDelegate pushLeft];
                }
                    break;
                case rightLeftPush:{
                    self.pushTransition = [UIPercentDrivenInteractiveTransition new];
                    self.pushTransition.completionCurve = UIViewAnimationCurveEaseOut;
                    self.type = leftPush;
                    [self.pushDelegate pushLeft];
                }
                    break;
                default:
                    break;
            }
            
        }else{
            switch (self.type) {
                case rightPop:
                {
                    self.popTransition = [UIPercentDrivenInteractiveTransition new];
                    [self.naVC popViewControllerAnimated:YES];
                }
                    break;
                case rightPush:
                {
                    self.pushTransition = [UIPercentDrivenInteractiveTransition new];
                    self.pushTransition.completionCurve = UIViewAnimationCurveEaseOut;
                    [self.pushDelegate pushRight];
                   
                }
                    break;
                case rightLeftPush:{
                    self.pushTransition = [UIPercentDrivenInteractiveTransition new];
                    self.pushTransition.completionCurve = UIViewAnimationCurveEaseOut;
                     self.type = rightPush;
                    [self.pushDelegate pushRight];
                }
                    break;
                default:
                    break;
            }
            
        }
        
        [self.pushTransition updateInteractiveTransition:0];
    }else if(gesture.state == UIGestureRecognizerStateChanged){
        
        if (self.type == leftPush || self.type == rightPush) {
            [self.pushTransition updateInteractiveTransition:progress];
        }else{
            [self.popTransition updateInteractiveTransition:progress];
        }
        
    }else if(gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled){
        if (self.type == leftPush || self.type == rightPush) {
            if (progress > 0.2) {
                [self.pushTransition finishInteractiveTransition];
            }else{
                [self.pushTransition cancelInteractiveTransition];
            }
        }else{
            if (progress > 0.2) {
                [self.popTransition finishInteractiveTransition];
            }else{
                [self.popTransition cancelInteractiveTransition];
            }
        }
        self.pushTransition = nil;
        self.popTransition = nil;
    }
    
    
    
}
@end
