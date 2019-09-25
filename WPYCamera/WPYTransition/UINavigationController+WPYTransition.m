//
//  UINavigationController+WPYTransition.m
//  WPYCamera
//
//  Created by 王鹏宇 on 5/28/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import "UINavigationController+WPYTransition.h"
#import "UIViewController+WPYTransition.h"
#import <objc/runtime.h>
#import "WPY_GestureRecognizerDelegate.h"


static const void * OpenScrollLeftPushKey = @"OpenScrollLeftPushKey";
static const void * CurrentVCKey = @"CurrentVCKey";

@implementation UINavigationController (WPYTransition)




- (void)viewDidLoad{
    
    [super viewDidLoad];
    // 设置代理
    self.delegate = self.navDelegate;
}


- (BOOL)openScrollLeftPush{
    
    return [objc_getAssociatedObject(self, OpenScrollLeftPushKey) boolValue];
}

- (void)setOpenScrollLeftPush:(BOOL)openScrollLeftPush{
    
    objc_setAssociatedObject(self, OpenScrollLeftPushKey, @(openScrollLeftPush), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIPanGestureRecognizer *)panGesture{
    
    UIPanGestureRecognizer * panGesture = objc_getAssociatedObject(self, _cmd);
    if (!panGesture) {
        panGesture = [[UIPanGestureRecognizer alloc] init];
        panGesture.maximumNumberOfTouches = 1;
        
        objc_setAssociatedObject(self, _cmd, panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return panGesture;
}

- (WPY_NavDelegate *)navDelegate{
    
    WPY_NavDelegate * delegate = objc_getAssociatedObject(self, _cmd);
    if (!delegate) {
        delegate = [WPY_NavDelegate new];
        delegate.naVC = self;
        delegate.pushDelegate = self;
        
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return delegate;
}



-(WPY_GestureRecognizerDelegate *)popGestureDelegate{
    
    WPY_GestureRecognizerDelegate * delegate = objc_getAssociatedObject(self, _cmd);
    if (!delegate) {
        delegate = [WPY_GestureRecognizerDelegate new];
        delegate.naVC = self;
        delegate.systemTarget = [self systemTarget];
        delegate.customTarget = [self navDelegate];
        
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return delegate;
}


- (id)systemTarget {
    NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
    id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
    
    return internalTarget;
}

- (UIScreenEdgePanGestureRecognizer *)screenPanGesture {
    UIScreenEdgePanGestureRecognizer *panGesture = objc_getAssociatedObject(self, _cmd);
    if (!panGesture) {
        panGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self.navDelegate action:@selector(directionPushPanGesture:)];
        panGesture.edges = UIRectEdgeLeft;
        
        objc_setAssociatedObject(self, _cmd, panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGesture;
}

- (BOOL)translationScale{
    
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setTranslationScale:(BOOL)translationScale{
    
     objc_setAssociatedObject(self, @selector(translationScale), @(translationScale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCurrrentVC:(UIViewController *)currrentVC{
    
    objc_setAssociatedObject(self, CurrentVCKey, currrentVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)currrentVC{
    
   return  objc_getAssociatedObject(self, CurrentVCKey);
}


-(void)addTransitionGestureWith:(UIViewController *)currentVC type:(WPYTransitionType)type{
    
    [self navDelegate].type = type;
    
        
//    UIViewController *currentVC = (UIViewController *)notify.object[@"viewController"];
    
    BOOL isRootVC = currentVC == self.viewControllers.firstObject;
    
    self.currrentVC = currentVC;
    
    if (currentVC.interactivePopDisabled) { //禁止滑动
        
        self.interactivePopGestureRecognizer.delegate = nil;
        self.interactivePopGestureRecognizer.enabled = false;
    }else if(currentVC.fullScreenPopDisabled){//禁止全屏滑动
        [self.interactivePopGestureRecognizer.view removeGestureRecognizer:[self panGesture]];
        
        
        self.interactivePopGestureRecognizer.delaysTouchesBegan = true;
        self.interactivePopGestureRecognizer.delegate =  [self popGestureDelegate];
        self.interactivePopGestureRecognizer.enabled = !isRootVC;
    }else{
        
        self.interactivePopGestureRecognizer.delegate = nil;
        self.interactivePopGestureRecognizer.enabled = false;
        
        [self.interactivePopGestureRecognizer.view removeGestureRecognizer:[self screenPanGesture]];
//    !isRootVC &&
        //给 self.interactivePopGestureRecognizer.view添加全屏滑动手势
        //self.interactivePopGestureRecognizer
        if (![currentVC.view.gestureRecognizers containsObject:[self panGesture]]) {
            [currentVC.view addGestureRecognizer:[self panGesture]];
            [self panGesture].delegate = [self popGestureDelegate];
        }
        
        if (self.openScrollLeftPush || self.visibleViewController.popDelegate) {
            [[self panGesture] addTarget:[self navDelegate] action:@selector(directionPushPanGesture:)];
        }else{
            SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
            [[self panGesture] addTarget:[self systemTarget] action:internalAction];
        }
    }
}


#pragma mark WPY_VCScrollPushDelegate

- (void)pushLeft{
    
    
    if ([self.currrentVC.pushDelegate respondsToSelector:@selector(pushLeftVC)]) {
        
        [self.currrentVC.pushDelegate pushLeftVC];
    }
    
}

-(void)pushRight{
    
    
    if ([self.currrentVC.pushDelegate respondsToSelector:@selector(pushRightVC)]) {
        
        [self.currrentVC.pushDelegate pushRightVC];
    }
}

@end
