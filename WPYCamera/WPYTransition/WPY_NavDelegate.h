//
//  WPY_NavDelegate.h
//  WPYCamera
//
//  Created by 王鹏宇 on 5/27/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WPY_TransitionUtil.h"
#import "UIScrollView+WPYTransition.h"

NS_ASSUME_NONNULL_BEGIN


@protocol WPY_VCScrollPushDelegate <NSObject>

@optional
//direction
-(void)pushLeft;
-(void)pushRight;

@end

@interface WPY_NavDelegate : NSObject<UINavigationControllerDelegate>

// push动画的百分比
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *pushTransition;

// pop动画的百分比
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *popTransition;

@property (nonatomic, assign)BOOL isLeft;

@property (nonatomic, weak)UINavigationController * naVC;
@property (nonatomic, weak)id<WPY_VCScrollPushDelegate> pushDelegate;

@property (nonatomic, assign)WPYTransitionType type;
// 手势Action

-(void)directionPushPanGesture:(UIPanGestureRecognizer *)gesture;
@end


NS_ASSUME_NONNULL_END
