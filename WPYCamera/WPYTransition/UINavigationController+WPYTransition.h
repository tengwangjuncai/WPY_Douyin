//
//  UINavigationController+WPYTransition.h
//  WPYCamera
//
//  Created by 王鹏宇 on 5/28/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPY_GestureRecognizerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (WPYTransition)<WPY_VCScrollPushDelegate>

//是否开启左滑push操作，默认是false
@property(nonatomic, assign)BOOL openScrollLeftPush;

@property(nonatomic, assign)BOOL translationScale;

@property (nonatomic, weak)WPY_NavDelegate * navDelegate;

@property (nonatomic, weak)UIViewController * currrentVC;

-(void)addTransitionGestureWith:(UIViewController *)currentVC type:(WPYTransitionType)type;
@end

NS_ASSUME_NONNULL_END
