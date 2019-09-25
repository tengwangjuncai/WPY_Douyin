//
//  Util_OC.m
//  WPYPlayer
//
//  Created by 王鹏宇 on 12/18/18.
//  Copyright © 2018 王鹏宇. All rights reserved.
//

#import "Util_OC.h"

@implementation Util_OC


+ (void)setAVAudioSessionCategory:(AVAudioSessionCategory) category {
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    [session setCategory:category withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
}

@end
