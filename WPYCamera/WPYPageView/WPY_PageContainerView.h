//
//  WPY_PageContainerView.h
//  WPYCamera
//
//  Created by 王鹏宇 on 6/26/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPY_PageTableView.h"
NS_ASSUME_NONNULL_BEGIN

@interface WPY_PageContainerView : UIView

@property(nonatomic,strong,readonly) UICollectionView * collectionView;

@property(nonatomic,weak)WPY_PageTableView * pageTableView;

@property(nonatomic,weak)id delegate;

-(void)reloadData;
@end

NS_ASSUME_NONNULL_END
