//
//  WPY_PageView.m
//  WPYCamera
//
//  Created by 王鹏宇 on 6/27/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import "WPY_PageView.h"


@interface WPY_PageView()

@property (nonatomic, strong) WPY_PageTableView * pageTableView;
@property (nonatomic, strong) WPY_PageContainerView * pageContainerView;
@property (nonatomic,strong) NSMutableDictionary <NSNumber *,id> *pagesDict;

//是否滑动到临界点，可有偏差
@property (nonatomic,assign) BOOL isCriticalPoint;

//是否到达临界点，无偏差
@property (nonatomic,assign) BOOL isCeillPoint;

//pageView 是否可以滑动
@property (nonatomic,assign) BOOL isPageViewCanScroll;

//containerView是否可以滑动
@property (nonatomic,assign) BOOL isContainerScroll;

//是否开始拖拽，
@property (nonatomic,assign) BOOL isBeginDragging;

//快速切换原点和临界点
@property (nonatomic,assign) BOOL isScrollToOriginal;
@property (nonatomic,assign) BOOL isScrollToCritical;

//是否加载
@property (nonatomic,assign) BOOL isLoaded;

//当前滑动页
@property (nonatomic,weak)UIScreen * currentPage;

@end


@implementation WPY_PageView


-(instancetype)initWithDelegate:(id<WPYPageScrollViewDelegate>)delegate{
    if (self = [super init]) {
        self.delegate = delegate;
        self.ceilPointHeight = 64;
        self.pagesDict = [NSMutableDictionary new];
        
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.pageTableView.frame  = self.bounds;
}

-(void)setup{
    
    self.isCriticalPoint = false;
    self.isPageViewCanScroll = true;
    self.isContainerScroll = false;
    
    self.pageTableView = [[WPY_PageTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self addSubview:self.pageTableView];
    self.pageTableView.dataSource = self;
    self.pageTableView.delegate = self;
    self.pageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.pageTableView.showsVerticalScrollIndicator = false;
    self.pageTableView.showsHorizontalScrollIndicator = false;
    self.pageTableView.tableHeaderView = [self.delegate headerViewInPageView:self];
    
    if (@available(iOS 11.0, *)) {
        self.pageTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
//    self.pageContainerView.pageTableView = self.pageTableView;
    
}


-(void)refreshHeaderView{
    
    self.pageTableView.tableHeaderView = [self.delegate headerViewInPageView:self];
}

-(void)reloadData{
    
    self.isLoaded = true;
    for (id list in self.pagesDict.allValues) {
        
    }
    
    [self.pageTableView reloadData];
}

-(void)horizonScrollViewWillBeginScroll{
    
    self.pageTableView.scrollEnabled = false;
}

-(void)horizonScrollViewDidEndedScroll{
    self.pageTableView.scrollEnabled = true;
}

- (void)scrollToOriginalPoint{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       
        if(self.isScrollToOriginal) return ;
        self.isScrollToOriginal = true;
        self.isCeillPoint = false;
        self.isPageViewCanScroll = true;
        self.isContainerScroll = false;
        
        [self.pageTableView setContentOffset:CGPointZero animated:true];
    });
}

-(void)scrollToCriticalPoint{
    
    if (self.isScrollToCritical) {
        return;
    }
    
    self.isScrollToCritical = true;
    CGFloat criticalPoint = [self.pageTableView rectForSection:0].origin.y - self.ceilPointHeight;
    
    [self.pageTableView setContentOffset:CGPointMake(0, criticalPoint) animated:true];
    self.isPageViewCanScroll = false;
    self.isContainerScroll = true;
    
    [self pageTableViewCanScrollUpdate];
}

-(void)pageTableViewCanScrollUpdate{
    
    if ([self.delegate respondsToSelector:@selector(pageTableViewDidScroll:isPageViewCanScroll:)]) {
        
        [self.delegate pageTableViewDidScroll:self.pageTableView isPageViewCanScroll:self.isPageViewCanScroll];
        
    }
}
@end
