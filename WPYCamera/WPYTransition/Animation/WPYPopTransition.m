//
//  WPYPopTransition.m
//  WPYCamera
//
//  Created by 王鹏宇 on 5/27/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import "WPYPopTransition.h"

@implementation WPYPopTransition


- (void)animateTransition{
    
    [self.containerView insertSubview:self.toVC.view belowSubview:self.fromVC.view];
    if (self.scale) {
        
    }else{
        self.toVC.view.frame = CGRectMake(-(0.3 * WPY_SCREENWIDTH), 0, WPY_SCREENWIDTH, WPY_SCREENHEIGHT);
    }
    
    //添加阴影
    self.fromVC.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.fromVC.view.layer.shadowOpacity = 0.5;
    self.fromVC.view.layer.shadowRadius = 8;
    
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext] animations:^{
        self.fromVC.view.frame = CGRectMake(WPY_SCREENWIDTH, 0, WPY_SCREENWIDTH, WPY_SCREENHEIGHT);
        
        self.toVC.view.frame = CGRectMake(0, 0, WPY_SCREENWIDTH, WPY_SCREENHEIGHT);
        
    } completion:^(BOOL finished) {
       
        [self completeTransition];
        [self.shadowView removeFromSuperview];
    }];
   
}
@end
