//
//  WPY_VCDelegate.h
//  TransitionTest
//
//  Created by 王鹏宇 on 6/13/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WPY_TransitionUtil.h"

#import "WPYPushTransition.h"
#import "WPYPopTransition.h"
#import "WPYPresentTransition.h"
#import "WPYDismissTransition.h"

NS_ASSUME_NONNULL_BEGIN

@interface WPY_VCDelegate : NSObject<UIViewControllerTransitioningDelegate>

// present动画的百分比
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *presentTransition;

// dismiss动画的百分比
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *dismissTransition;

@property (nonatomic, assign)BOOL isLeft;


@property (nonatomic, assign)WPYTransitionType type;

@end

NS_ASSUME_NONNULL_END
