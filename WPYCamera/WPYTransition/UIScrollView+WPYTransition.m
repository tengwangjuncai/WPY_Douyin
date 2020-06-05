//
//  UIScrollView+WPYTransition.m
//  WPYCamera
//
//  Created by 王鹏宇 on 6/26/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import "UIScrollView+WPYTransition.h"

@implementation UIScrollView (WPYTransition)

//当UIScrollView在水平方向滑动动第一个时，默认是不能全屏滑动返回的，通过下面的方法实现滑动返回

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    if ([self backGesture:gestureRecognizer])
    {
        return false;
    }
    return true;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([self backGesture:gestureRecognizer])
    {
        return YES;
    }
    
    return NO;
}


- (BOOL)backGesture:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer == self.panGestureRecognizer)
    {
        
        CGPoint point = [self.panGestureRecognizer translationInView:self];
        UIGestureRecognizerState state = gestureRecognizer.state;
        
        //设置手势滑动位置距离屏幕左边的区域
        CGFloat locationDistance = [UIScreen mainScreen].bounds.size.width;
        if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStatePossible)
        {
            
            CGPoint location = [gestureRecognizer locationInView:self];
            //判断 手势滑动方向，滑动左边距离是否小于规定距离  scrollView 是否滑动到头
            if (point.x > 0 && location.x < locationDistance && self.contentOffset.x <= 0) {
                return true;
            }
        }
    }
    
    return false;
}
@end
