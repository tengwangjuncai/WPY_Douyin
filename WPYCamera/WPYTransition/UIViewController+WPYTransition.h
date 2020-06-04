//
//  UIViewController+WPYTransition.h
//  WPYCamera
//
//  Created by 王鹏宇 on 5/28/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPY_VCDelegate.h"

@protocol WPY_VCPushDelegate <NSObject>

@optional
-(void)pushLeftVC;
-(void)pushRightVC;

@end

@protocol WPY_VCPopDelegate <NSObject>

@optional
-(void)viewControllerPopScrollBegan;
-(void)viewControllerPopSCrollChange:(float)progress;
-(void)viewControllerPopSCrollEnded;

@end

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (WPYTransition)

//是否禁止当前控制器的滑动返回(包括全屏返回和边缘返回)
@property(nonatomic, assign)BOOL interactivePopDisabled;
//是否禁止当前控制器的全屏滑动返回
@property(nonatomic,assign)BOOL fullScreenPopDisabled;

//全屏滑动时，滑动区域距离屏幕左边的最大位置，默认是0
@property(nonatomic,assign)CGFloat popMaxAllowedDistanceToLeftEdge;

@property(nonatomic, weak)id<WPY_VCPushDelegate>pushDelegate;
@property(nonatomic,weak)id<WPY_VCPopDelegate>popDelegate;

@property(nonatomic, weak)WPY_VCDelegate * customTransitionDelegate;

@property(nonatomic, assign)WPYTransitionType transitionType;

@end

NS_ASSUME_NONNULL_END
