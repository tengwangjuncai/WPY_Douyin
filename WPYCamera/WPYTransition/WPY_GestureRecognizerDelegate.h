//
//  WPY_GestureRecognizerDelegate.h
//  WPYCamera
//
//  Created by 王鹏宇 on 5/27/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WPY_NavDelegate.h"

#import "UIViewController+WPYTransition.h"

NS_ASSUME_NONNULL_BEGIN


@interface WPY_GestureRecognizerDelegate : NSObject<UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController * naVC;

//系统手势返回
@property (nonatomic, weak)id systemTarget;

@property (nonatomic, weak)WPY_NavDelegate *customTarget;

@end

NS_ASSUME_NONNULL_END
