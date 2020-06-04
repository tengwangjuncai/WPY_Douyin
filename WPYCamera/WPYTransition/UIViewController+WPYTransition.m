//
//  UIViewController+WPYTransition.m
//  WPYCamera
//
//  Created by 王鹏宇 on 5/28/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import "UIViewController+WPYTransition.h"
#import <objc/runtime.h>

static const void * InteractivePopDisabledKey = @"InteractivePopDisabledKey";

static const void * FullScreenPopDisabledKey = @"FullScreenPopDisabledKey";

static const void * PopMaxDistanceKey = @"PopMaxDistanceKey";

static const void * PushDelegateKey = @"PushDelegateKey";

static const void * PopDelegateKey = @"PopDelegateKey";

static const void * CustomTransitionDelegateKey = @"CustomTransitionDelegateKey";


@implementation UIViewController (WPYTransition)


- (BOOL)interactivePopDisabled{
    
    return  [objc_getAssociatedObject(self, InteractivePopDisabledKey) boolValue];
}

- (void)setInteractivePopDisabled:(BOOL)interactivePopDisabled{
    
    objc_setAssociatedObject(self, InteractivePopDisabledKey, @(interactivePopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (BOOL)fullScreenPopDisabled{
    
    return [objc_getAssociatedObject(self, FullScreenPopDisabledKey) boolValue];
}

- (void)setFullScreenPopDisabled:(BOOL)fullScreenPopDisabled{
    
    objc_setAssociatedObject(self, FullScreenPopDisabledKey, @(fullScreenPopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    //可以通知改变
}


- (CGFloat)popMaxAllowedDistanceToLeftEdge{
    
    return [objc_getAssociatedObject(self, PopMaxDistanceKey) floatValue];
}

- (void)setPopMaxAllowedDistanceToLeftEdge:(CGFloat)popMaxAllowedDistanceToLeftEdge{
    
    objc_setAssociatedObject(self, PopMaxDistanceKey, @(popMaxAllowedDistanceToLeftEdge), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    //通知改变
}

- (id<WPY_VCPushDelegate>)pushDelegate{
    
    return objc_getAssociatedObject(self,PushDelegateKey);
}

- (void)setPushDelegate:(id<WPY_VCPushDelegate>)pushDelegate{
    
    objc_setAssociatedObject(self, PushDelegateKey, pushDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(id<WPY_VCPopDelegate>)popDelegate{
    
     return objc_getAssociatedObject(self,PopDelegateKey);
}

-(void)setPopDelegate:(id<WPY_VCPopDelegate>)popDelegate{
    objc_setAssociatedObject(self, PopDelegateKey, popDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setTransitionType:(WPYTransitionType)transitionType{
    WPY_VCDelegate * delegate = objc_getAssociatedObject(self, CustomTransitionDelegateKey);
    if (!delegate) {
        delegate = [WPY_VCDelegate new];
        objc_setAssociatedObject(self, CustomTransitionDelegateKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    delegate.type = transitionType;
    self.transitioningDelegate = delegate;
}


- (WPYTransitionType)transitionType{
    
    WPY_VCDelegate * delegate = objc_getAssociatedObject(self, CustomTransitionDelegateKey);
    
    return delegate.type;
}
@end
