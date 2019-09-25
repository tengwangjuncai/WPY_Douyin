//
//  WPY_VCDelegate.m
//  TransitionTest
//
//  Created by 王鹏宇 on 6/13/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import "WPY_VCDelegate.h"

@implementation WPY_VCDelegate




#pragma mark   -- present 代理方法

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {

    if (self.type == rightPresent) {

        return [WPYPresentTransition transitionManager];
    }else if(self.type == leftPresent){
        
        return [WPYPushTransition transitionManager];
    }

    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{

    if(self.type == leftDismiss ){
        return [WPYDismissTransition transitionManager];
    }else if(self.type == rightDismiss){
        return [WPYPopTransition transitionManager];
    }
    return nil;
}
- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator{

    return  self.dismissTransition;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator{

    return  self.presentTransition;
}

@end
