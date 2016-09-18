//
//  YJCycleScrollView.m
//  YJCycleScrollView
//
//  Created by Jet on 16/9/2.
//  Copyright © 2016年 Jet. All rights reserved.
//

#import "YJCycleScrollView.h"
#import "YJCycleScrollViewLayout.h"

#define kScreenWidth__YJ [UIScreen mainScreen].bounds.size.width

static const CGFloat kDefaultItemHeight = 50;
static NSString *const kYJCycleScrollViewReuseID = @"YJ_CycleScrollViewReuseID";
static const CGFloat kDefaultPageControlMargin = 10.0;

@interface YJCycleScrollView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic, weak, readwrite) UICollectionView *collectionView;
@property(nonatomic, weak, readwrite) UIPageControl *pageControl;
//@property(nonatomic, weak) UICollectionViewLayout *otherLayout;

@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, assign) BOOL calculateMaxOffset;
@property(nonatomic, assign) BOOL scrolling;

@end

@implementation YJCycleScrollView {
    CGFloat _scrollLoopEndOffset;
    CGFloat _scrollLoopBeginOffset;
    CGFloat _contentLength;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultPreferences];
        [self startInitalize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self defaultPreferences];
        [self startInitalize];
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self setupTimer];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
    [self configurePageControlLocation];
    
    if (CGSizeEqualToSize(_itemSize, CGSizeMake(kScreenWidth__YJ, kDefaultItemHeight))) {
        if (!CGSizeEqualToSize(_itemSize, CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)))) self.itemSize = CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    }
}

- (void)defaultPreferences {
    _pageIndicatorTintColor = [UIColor lightGrayColor];
    _currentPageIndicatorTintColor = [UIColor whiteColor];
    _pageControlInsets = UIEdgeInsetsMake(0, kDefaultPageControlMargin, kDefaultPageControlMargin, kDefaultPageControlMargin);
    _itemSize = CGSizeMake(kScreenWidth__YJ, kDefaultItemHeight);
    _scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _itemLineSpacing = 0;
    _pageControlLocation = YJCycleScrollViewPageControlLocationBottomCenter;
    _autoScroll = YES;
    _showPageControl = YES;
    _cellContentType = YJCycleScrollViewNormalCellContentTypeBoth;
    _autoScrollTimeInterval = 2.0;
    _cellTitleTextColor = [UIColor blackColor];
    _cellTitleBackgroundColor = [UIColor whiteColor];
}

- (void)startInitalize {
    YJCycleScrollViewLayout *layout = [[YJCycleScrollViewLayout alloc] init];
    layout.itemSize = _itemSize;
    layout.scrollDirection = _scrollDirection;
    layout.minimumLineSpacing = _itemLineSpacing;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollsToTop = NO;
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    
    [self makePageControl];
}

- (void)makePageControl {
    UIPageControl *page = [[UIPageControl alloc] init];
    page.pageIndicatorTintColor = self.pageIndicatorTintColor;
    page.currentPageIndicatorTintColor = self.currentPageIndicatorTintColor;
    [self addSubview:page];
    self.pageControl = page;
}

- (void)setupTimer {
    [self removeTimer];
    if (self.autoScroll) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:_autoScrollTimeInterval target:self selector:@selector(autoScrollToNextItem) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)removeTimer {
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)pauseTimer {
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)fireTimer {
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    
}

- (void)autoScrollToNextItem {
    CGPoint targetPoint = CGPointZero;
    
    switch (_scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal: {
            CGFloat currentOffsetX = _collectionView.contentOffset.x;
            CGFloat targetOffsetX = currentOffsetX + _itemLineSpacing + _itemSize.width;
            targetPoint = CGPointMake(targetOffsetX, _collectionView.contentOffset.y);
            break;
        }
            
        case UICollectionViewScrollDirectionVertical: {
            CGFloat currentOffsetY = _collectionView.contentOffset.y;
            CGFloat targetOffsetY = currentOffsetY + _itemLineSpacing + _itemSize.height;
            targetPoint = CGPointMake(_collectionView.contentOffset.x, targetOffsetY);
            break;
        }
    }
    
    _collectionView.userInteractionEnabled = NO;
    [_collectionView setContentOffset:targetPoint animated:YES];
    /**
     *  iOS animation duration is 0.25s.
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _collectionView.userInteractionEnabled = YES;
    });
}

- (void)notifyDisplayLocation {
    NSInteger currentPage = [self getCurrentPage];
    if ([self.delegate respondsToSelector:@selector(yj_cycleScrollView:didDisplayItemAtIndexPath:)]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentPage inSection:0];
        [self.delegate yj_cycleScrollView:self didDisplayItemAtIndexPath:indexPath];
    }
}

- (void)configurePageControlIndicator {
    if (!_showPageControl) return;
    
    _pageControl.currentPage = [self getCurrentPage];
}

- (NSInteger)getCurrentPage {
    if (_dataSource.count == 0) return 0;
    
    CGFloat offset = 0;
    CGFloat length = 0;
    NSInteger index = 0;
    switch (_scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal: {
            offset = _collectionView.contentOffset.x;
            length = _collectionView.bounds.size.width;
            break;
        }
            
        case UICollectionViewScrollDirectionVertical: {
            offset = _collectionView.contentOffset.y;
            length = _collectionView.bounds.size.height;
            break;
        }
    }
    index = offset / length;
    return index % _dataSource.count;
}

- (void)calculateScrollLoopOffset {
    CGFloat itemLength;
    CGFloat itemsCount = _dataSource.count;
    
    switch (self.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal: {
            itemLength = _itemSize.width + _itemLineSpacing;
            break;
        }
            
        case UICollectionViewScrollDirectionVertical: {
            itemLength = _itemSize.height + _itemLineSpacing;
            break;
        }
    }
    
    _contentLength = itemLength * itemsCount;
    _scrollLoopBeginOffset = _contentLength;
    _scrollLoopEndOffset = _contentLength * 2;
    
    _calculateMaxOffset = YES;
}

- (void)configurePageControlLocation {
    if (!_showPageControl) return;
    NSInteger count = (!_dataSource) ? 0 : _dataSource.count;
    
    CGRect frame = _pageControl.frame;
    CGFloat width = 20 * count;
    CGFloat height = 20;
    
    frame.size.width = width;
    frame.size.height = height;
    frame.origin.y = CGRectGetHeight(self.bounds) - height - _pageControlInsets.bottom;

    switch (_pageControlLocation) {
        case YJCycleScrollViewPageControlLocationBottomLeft: {
            frame.origin.x = _pageControlInsets.left;
            break;
        }
            
        case YJCycleScrollViewPageControlLocationBottomCenter: {
            frame.origin.x = (CGRectGetWidth(self.bounds) - width) * 0.5;
            break;
        }
            
        case YJCycleScrollViewPageControlLocationBottomRight: {
            frame.origin.x = CGRectGetMaxX(self.bounds) - _pageControlInsets.right - width;
            break;
        }
    }
    _pageControl.frame = frame;
}

- (NSInteger)getCorrentIndexForCurrentRow:(NSInteger)row {
    NSInteger count = self.dataSource.count;
    return row % count;
}

- (NSIndexPath *)getCorrentIndexPathForCurrentRowPath:(NSIndexPath *)rowPath {
    NSInteger correntRow = [self getCorrentIndexForCurrentRow:rowPath.row];
    return [NSIndexPath indexPathForRow:correntRow inSection:rowPath.section];
}

#pragma mark - UICollectionView Delegate/DataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [self getCorrentIndexForCurrentRow:indexPath.row];

    indexPath = [self getCorrentIndexPathForCurrentRowPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(yj_innerCollectionView:acquireCellForItemAtIndexPath:)]) {
        return [self.delegate yj_innerCollectionView:self.collectionView acquireCellForItemAtIndexPath:indexPath];
    }
    
    YJCycleScrollViewNormalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYJCycleScrollViewReuseID forIndexPath:indexPath];

    cell.contentType = _cellContentType;
    
    NSObject *data = self.dataSource[index];

    if ([data respondsToSelector:@selector(yj_cycleScrollViewCellTitle)]) {
        NSString *title = [(id<YJCycleScrollViewCellDataSource>)data yj_cycleScrollViewCellTitle];
        if (title != nil) cell.titleLabel.text = title;
    }
    if ([data respondsToSelector:@selector(yj_cycleScrollViewCellAttributedTitle)]) {
        NSAttributedString *title = [(id<YJCycleScrollViewCellDataSource>)data yj_cycleScrollViewCellAttributedTitle];
        if (title != nil) cell.titleLabel.attributedText = title;
    }
    if ([data respondsToSelector:@selector(yj_cycleScrollViewCellImageUrl)]) {
        NSString *imageUrl = [(id<YJCycleScrollViewCellDataSource>)data yj_cycleScrollViewCellImageUrl];
        if ([self.delegate respondsToSelector:@selector(yj_decideCellImageview:downloadImageModeWithImageUrl:)]) {
            [self.delegate yj_decideCellImageview:cell.imgView downloadImageModeWithImageUrl:imageUrl];
        }
    }
    
    if (_cellContentType != YJCycleScrollViewNormalCellContentTypeOnlyImage) {
        cell.titleLabel.backgroundColor = _cellTitleBackgroundColor;
        cell.titleLabel.textColor = _cellTitleTextColor;
    }

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = self.dataSource.count;
    
    if (self.delegate == nil) {
        [self.collectionView registerClass:[YJCycleScrollViewNormalCell class] forCellWithReuseIdentifier:kYJCycleScrollViewReuseID];
    }
    
    return count * 3;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *realIndexPath = [self getCorrentIndexPathForCurrentRowPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(yj_cycleScrollView:didSelectItemAtIndexPath:)]) {
        [self.delegate yj_cycleScrollView:self didSelectItemAtIndexPath:realIndexPath];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self fireTimer];

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self notifyDisplayLocation];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!_calculateMaxOffset) [self calculateScrollLoopOffset];
    
    CGPoint targetOffset = _collectionView.contentOffset;
    
    switch (self.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal: {
            CGFloat currentOffset = self.collectionView.contentOffset.x;
            if (currentOffset < _scrollLoopBeginOffset) {
                targetOffset.x = currentOffset + _contentLength;
            }
            else if (currentOffset > _scrollLoopEndOffset) {
                targetOffset.x = currentOffset - _contentLength;
            }
            
            break;
        }
            
        case UICollectionViewScrollDirectionVertical: {
            CGFloat currentOffset = self.collectionView.contentOffset.y;
            if (currentOffset < _scrollLoopBeginOffset) {
                targetOffset.y = currentOffset + _contentLength;
            }
            else if (currentOffset > _scrollLoopEndOffset) {
                targetOffset.y = currentOffset - _contentLength;
            }
            
            break;
        }
    }
    [_collectionView setContentOffset:targetOffset];
    [self configurePageControlIndicator];
}


#pragma mark - Setter/Getter
- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    _scrollDirection = scrollDirection;
    YJCycleScrollViewLayout *layout = (YJCycleScrollViewLayout *)self.collectionView.collectionViewLayout;
    layout.scrollDirection = scrollDirection;
}

- (void)setItemSize:(CGSize)itemSize {
    _itemSize = itemSize;
    YJCycleScrollViewLayout *layout = (YJCycleScrollViewLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = itemSize;
}

- (void)setItemLineSpacing:(CGFloat)itemLineSpacing {
    _itemLineSpacing = itemLineSpacing;
    YJCycleScrollViewLayout *layout = (YJCycleScrollViewLayout *)self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = itemLineSpacing;
}

- (void)setAutoScroll:(BOOL)autoScroll {
    _autoScroll = autoScroll;
    if (!autoScroll) {
        [self removeTimer];
    }
    else {
        [self setupTimer];
    }
}

- (void)setAutoScrollTimeInterval:(NSTimeInterval)autoScrollTimeInterval {
    _autoScrollTimeInterval = autoScrollTimeInterval;
    [self setupTimer];
}

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
    
    self.pageControl.numberOfPages = dataSource.count;
    self.pageControl.currentPage = 0;
    
    [self.collectionView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (_scrollDirection) {
            case UICollectionViewScrollDirectionHorizontal:
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:dataSource.count inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                break;
                
            case UICollectionViewScrollDirectionVertical:
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:dataSource.count inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                break;
        }
        
        [self notifyDisplayLocation];
    });
}

- (void)setDelegate:(id<YJCycleScrollViewDelegate>)delegate {
    _delegate = delegate;
    if ([_delegate respondsToSelector:@selector(yj_registerCellClassForInnerCollectionView:)]) {
        [_delegate yj_registerCellClassForInnerCollectionView:self.collectionView];
    }
    else {
        [self.collectionView registerClass:[YJCycleScrollViewNormalCell class] forCellWithReuseIdentifier:kYJCycleScrollViewReuseID];
    }
}

- (void)setPageControlLocation:(YJCycleScrollViewPageControlLocation)pageControlLocation {
    _pageControlLocation = pageControlLocation;
    [self configurePageControlLocation];
}

- (void)setPageControlInsets:(UIEdgeInsets)pageControlInsets {
    _pageControlInsets = pageControlInsets;
    [self configurePageControlLocation];
}

- (void)setShowPageControl:(BOOL)showPageControl {
    _showPageControl = showPageControl;
    if (!showPageControl) {
        [self.pageControl removeFromSuperview];
        self.pageControl = nil;
    }
    else {
        [self makePageControl];
    }
}

@end
