//
//  WPY_PageTableView.m
//  WPYCamera
//
//  Created by 王鹏宇 on 6/26/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import "WPY_PageTableView.h"

@implementation WPY_PageTableView

//允许多个手势

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


@end
