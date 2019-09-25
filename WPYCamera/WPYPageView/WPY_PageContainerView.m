//
//  WPY_PageContainerView.m
//  WPYCamera
//
//  Created by 王鹏宇 on 6/26/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

#import "WPY_PageContainerView.h"


@interface WPY_PageContainerView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong)UICollectionView * collectionView;

@end


@implementation WPY_PageContainerView



-(void)setup{
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.showsVerticalScrollIndicator = false;
    self.collectionView.showsHorizontalScrollIndicator = false;
    self.collectionView.pagingEnabled = true;
    self.collectionView.scrollsToTop = false;
    self.collectionView.bounces = false;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    if (@available(iOS 10.0, *)) {
        self.collectionView.prefetchingEnabled = false;
    }
    
    if (@available(iOS 11.0,*)) {
        
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:self.collectionView];
    
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
}

-(void)reloadData{
    
    [self.collectionView reloadData];
}


#pragma mark ---- UICollectionViewDataSource,UICollectionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//    cell.contentView.subviews makeObjectsPerformSelector:
    
    UIView * pageView;
    pageView.frame = cell.bounds;
    [cell.contentView addSubview:pageView];
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return false;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    self.pageTableView.scrollEnabled = true;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    self.pageTableView.scrollEnabled = true;
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    self.pageTableView.scrollEnabled = true;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.isDecelerating || scrollView.isTracking) {
        self.pageTableView.scrollEnabled = false;
    }
}


#pragma mark -- UICollectionViewDelegateFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return self.bounds.size;
}


@end
