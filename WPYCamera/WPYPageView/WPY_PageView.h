//
//  WPY_PageView.h
//  WPYCamera
//
//  Created by 王鹏宇 on 6/27/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPY_PageTableView.h"
#import "WPY_PageContainerView.h"

NS_ASSUME_NONNULL_BEGIN

@class WPY_PageView;

@protocol WPYPageScrollViewDelegate <NSObject>

@required
/**
 返回tableView 的HeaderView

 @param pageView ---
 @return ----
 */
-(UIView *)headerViewInPageView:(WPY_PageView *)pageView;

@optional


/**
 返回分页视图

 @param pageView pageView
 @return pageView
 */
-(UIView *)pageInPageView:(WPY_PageView *)pageView;



/**
 
 返回实现代理的子页面 控制器
 @param pageView
 @return
 */


-(NSArray <id> *)scrollPagesInPageView:(WPY_PageView *)pageView;


/**
 开始拖拽

 @param scrollView
 */
-(void)pageTableViewWillBeginDragging:(UIScrollView *)scrollView;


/**
 pageView 滑动，用于导航栏渐变，头图缩放等

 @param scrollView
 @param isCanScroll
 */
-(void)pageTableViewDidScroll:(UIScrollView *)scrollView isPageViewCanScroll:(BOOL)isCanScroll;


/**
 pageView 结束拖拽

 @param scrollView
 @param decelerate
 */
-(void)pageTableViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;


/**
 结束减速滑动

 @param scrollView
 */

-(void)pageTableViewDidEndDecelerating:(UIScrollView *)scrollView;

@end



@interface WPY_PageView : UIView


@property (nonatomic,strong,readonly)WPY_PageTableView * pageTableView;

@property (nonatomic,strong,readonly)WPY_PageContainerView * pageContainerView;

@property (nonatomic,strong,readonly)NSDictionary <NSNumber *,id> *pagesDict;

//吸顶临界点高度 (默认值:状态栏+导航栏)
@property (nonatomic,assign)CGFloat ceilPointHeight;

//是否允许子列表下拉刷新
@property (nonatomic,assign)BOOL isAllowListRefresh;

//是否在吸顶状态下禁止pageTableView滑动
@property (nonatomic,assign)BOOL isDisableMainScrollInCeil;

//是否懒加载列表（默认为false）
@property (nonatomic,assign)BOOL isLazyLoadList;

@property (nonatomic,weak)id<WPYPageScrollViewDelegate> delegate;


-(instancetype)initWithDelegate:(id<WPYPageScrollViewDelegate>)delegate;
/**
 刷新headerView，headerView高度改变时调用
 */
-(void)refreshHeaderView;


/**
 刷新数据，刷新后pageView才能显示出来
 */
-(void)reloadData;


/**
 处理左右滑动与上下滑动的冲突
 */
-(void)horizonScrollViewWillBeginScroll;
-(void)horizonScrollViewDidEndedScroll;


/**
 滑动到原点，可用于在吸顶状态下，点击返回按钮，回到原始状态
 */
-(void)scrollToOriginalPoint;

-(void)scrollToCriticalPoint;

//用于自行处理滑动
-(void)pageScrollViewDidScroll:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
