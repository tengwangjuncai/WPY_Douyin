//
//  WPYBaseTransition.h
//  WPYCamera
//
//  Created by 王鹏宇 on 5/27/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define WPY_SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define WPY_SCREENHEIGHT [UIScreen mainScreen].bounds.size.height



NS_ASSUME_NONNULL_BEGIN

@interface WPYBaseTransition : NSObject<UIViewControllerAnimatedTransitioning>


@property (nonatomic,strong)UIView * shadowView;
@property (nonatomic,weak)id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic,weak)UIView * containerView;

@property (nonatomic, weak)UIViewController * fromVC;
@property (nonatomic, weak)UIViewController * toVC;

@property (nonatomic,assign)NSTimeInterval transitionTime;

+(instancetype)transitionManager;

-(void)animateTransition;

-(void)completeTransition;


@end

NS_ASSUME_NONNULL_END
