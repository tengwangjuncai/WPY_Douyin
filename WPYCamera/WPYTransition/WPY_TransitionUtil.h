//
//  WPY_TransitionUtil.h
//  TransitionTest
//
//  Created by 王鹏宇 on 6/13/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#ifndef WPY_TransitionUtil_h
#define WPY_TransitionUtil_h


#define NS_ENUM(...) CF_ENUM(__VA_ARGS__)

typedef NS_ENUM(NSInteger,WPYTransitionType){
    //手势移动方向   Gesture direction
    
    leftPop = 1,
    rightPop = 2,
    leftPush = 3,
    rightPush = 4,
    rightLeftPush = 5,
    
    leftPresent = 6,
    rightDismiss = 7,
    rightPresent = 8,
    leftDismiss = 9,
};


#endif /* WPY_TransitionUtil_h */
