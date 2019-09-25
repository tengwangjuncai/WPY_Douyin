//
//  WPYDismissTransition.m
//  TransitionTest
//
//  Created by 王鹏宇 on 5/31/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import "WPYDismissTransition.h"

@implementation WPYDismissTransition

- (void)animateTransition{
    
    [self.containerView addSubview:self.toVC.view];
    
    self.toVC.view.frame = CGRectMake(WPY_SCREENWIDTH, 0, WPY_SCREENWIDTH, WPY_SCREENHEIGHT);
    
    self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WPY_SCREENWIDTH, WPY_SCREENHEIGHT)];
    self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [self.fromVC.view addSubview:self.shadowView];
    
    self.toVC.view.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.toVC.view.layer.shadowOpacity = 0.6;
    self.toVC.view.layer.shadowRadius = 8;
    
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext] animations:^{
       
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        self.fromVC.view.transform = CGAffineTransformMakeScale(0.90, 0.90);
        self.toVC.view.frame = CGRectMake(0, 0, WPY_SCREENWIDTH, WPY_SCREENHEIGHT);
        
        
    } completion:^(BOOL finished) {
        [self completeTransition];
        self.fromVC.view.transform = CGAffineTransformIdentity;
        [self.shadowView removeFromSuperview];
    }];
}
@end
