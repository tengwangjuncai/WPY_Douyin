//
//  Util_OC.h
//  WPYPlayer
//
//  Created by 王鹏宇 on 12/18/18.
//  Copyright © 2018 王鹏宇. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Util_OC : NSObject

/**
 因为swift4.2 不支持10.0以下的
 
 @param category category
 */
+ (void)setAVAudioSessionCategory:(AVAudioSessionCategory) category;

@end

NS_ASSUME_NONNULL_END
