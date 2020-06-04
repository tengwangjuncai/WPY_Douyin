//
//  WPYPushTransition.m
//  WPYCamera
//
//  Created by 王鹏宇 on 5/27/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import "WPYPushTransition.h"

@implementation WPYPushTransition



- (void)animateTransition{
    
    [self.containerView addSubview:self.toVC.view];
    
    //设置转场前的Frame
    self.toVC.view.frame = CGRectMake(WPY_SCREENWIDTH, 0, WPY_SCREENWIDTH, WPY_SCREENHEIGHT);
    
    if (self.scale) {
        //初始化阴影添加
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WPY_SCREENWIDTH, WPY_SCREENHEIGHT)];
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        [self.fromVC.view addSubview:self.shadowView];
    }
    
    self.toVC.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.toVC.view.layer.shadowOpacity = 0.6;
    self.toVC.view.layer.shadowRadius = 8;
    
    //执行动画
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext] animations:^{
        
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        if (self.scale) {
            
        }else{
            
            self.fromVC.view.frame = CGRectMake(-(0.3 * WPY_SCREENWIDTH), 0, WPY_SCREENWIDTH, WPY_SCREENHEIGHT);
        }
        
        self.toVC.view.frame = CGRectMake(0, 0, WPY_SCREENWIDTH, WPY_SCREENHEIGHT);
        
        
    } completion:^(BOOL finished) {
        [self completeTransition];
        [self.shadowView removeFromSuperview];
    }];
    
}
@end
