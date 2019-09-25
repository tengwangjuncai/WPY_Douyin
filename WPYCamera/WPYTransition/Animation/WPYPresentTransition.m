//
//  WPYPresentTransition.m
//  TransitionTest
//
//  Created by 王鹏宇 on 5/31/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import "WPYPresentTransition.h"

@implementation WPYPresentTransition


- (void)animateTransition{
    
    [self.containerView insertSubview:self.toVC.view belowSubview:self.fromVC.view];
    
    self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WPY_SCREENWIDTH, WPY_SCREENHEIGHT)];
    self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.toVC.view addSubview:self.shadowView];
    
    self.toVC.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
    
    self.fromVC.view.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.fromVC.view.layer.shadowOpacity = 0.5;
    self.fromVC.view.layer.shadowRadius = 8;
    
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext] animations:^{
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        
        self.fromVC.view.frame = CGRectMake(WPY_SCREENWIDTH, 0, WPY_SCREENWIDTH, WPY_SCREENHEIGHT);
        self.toVC.view.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        [self completeTransition];
        [self.shadowView removeFromSuperview];
    }];
    
}
@end
