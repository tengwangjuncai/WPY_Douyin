//
//  WPY_GestureRecognizerDelegate.m
//  WPYCamera
//
//  Created by 王鹏宇 on 5/27/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import "WPY_GestureRecognizerDelegate.h"
#import "UINavigationController+WPYTransition.h"

@implementation WPY_GestureRecognizerDelegate


- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    
    UIViewController * visibleVC = self.naVC.visibleViewController;
    
    if (self.naVC.openScrollLeftPush) {
        //开启了左滑功能
    }else if(visibleVC.popDelegate){
        //设置了popDelegate
    }else{
        
    }
    
    //忽略禁用手势
    if (visibleVC.interactivePopDisabled) {
        return false;
    }
    

    
    CGPoint transition = [gestureRecognizer translationInView:gestureRecognizer.view];
    
    SEL action = NSSelectorFromString(@"handleNavigationTransition:");
    
    
    [gestureRecognizer removeTarget:self.systemTarget action:action];
    [gestureRecognizer addTarget:self.customTarget action:@selector(directionPushPanGesture:)];
    
    
//    if (transition.x >= 0) { //左滑处理
//
//        if (self.naVC.openScrollLeftPush && visibleVC.pushDelegate) {
//            // 开启了左滑push并设置了代理
//            [gestureRecognizer removeTarget:self.systemTarget action:action];
//            [gestureRecognizer addTarget:self.customTarget action:@selector(transitionePanGestureAction:)];
//        }else{
//            return false;
//        }
//
//    }else {//右滑处理
//
//        // 解决根控制器右滑时出现的卡死情况
//        if (visibleVC.popDelegate) {
//
//        }else{
//            if (self.naVC.viewControllers.count <= 1) {
//                return false;
//            }
//        }
//
//        // 全屏滑动时起作用
//        if (!visibleVC.fullScreenPopDisabled) {
//            // 上下滑动
//            if (transition.x == 0) return NO;
//        }
//
//        //忽略超出手势区域
//        CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
//
//        /** 全屏滑动时，滑动区域距离屏幕左边的最大位置，默认是0：表示全屏都可滑动 */
//        CGFloat maxAllowDistance = 0;
//
//        if (maxAllowDistance > 0 && beginningLocation.x > maxAllowDistance) {
//
//            return false;
//        }else if(visibleVC.popDelegate){
//
//            [gestureRecognizer removeTarget:self.systemTarget action:action];
//            [gestureRecognizer addTarget:self.customTarget action:@selector(transitionePanGestureAction:)];
//        }else if(!self.naVC.translationScale){
//
//
////            [gestureRecognizer removeTarget:self.customTarget action:@selector(transitionePanGestureAction:)];
////            [gestureRecognizer addTarget:self.systemTarget action:action];
//            [gestureRecognizer removeTarget:self.systemTarget action:action];
//            [gestureRecognizer addTarget:self.customTarget action:@selector(transitionePanGestureAction:)];
//
//        }else{
//
//            [gestureRecognizer removeTarget:self.systemTarget action:action];
//            [gestureRecognizer addTarget:self.customTarget action:@selector(transitionePanGestureAction:)];
//        }
//
//    }
    
    //忽略导航控制器正在做转场动画
    if([[self.naVC valueForKey:@"_isTransitioning"] boolValue]){
        return false;
    }
    
    return true;
}



@end

