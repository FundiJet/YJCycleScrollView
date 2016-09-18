//
//  YJCycleScrollView.h
//  YJCycleScrollView
//
//  Created by Jet on 16/9/2.
//  Copyright © 2016年 Jet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJCycleScrollViewNormalCell.h"

@protocol YJCycleScrollViewDelegate, YJCycleScrollViewCellDataSource;

typedef NS_ENUM(NSInteger, YJCycleScrollViewPageControlLocation) {
    YJCycleScrollViewPageControlLocationBottomLeft = 1,
    YJCycleScrollViewPageControlLocationBottomCenter,
    YJCycleScrollViewPageControlLocationBottomRight,
};

NS_ASSUME_NONNULL_BEGIN

@interface YJCycleScrollView : UIView

/**
 *  内部的 collectionView
 */
@property(nonatomic, weak, readonly) UICollectionView *collectionView;
/**
 *  分页指示符
 */
@property(nonatomic, weak, readonly) UIPageControl *pageControl;
/**
 *  数据源，如果使用默认的 YJCycleScrollViewNormalCell，需要注意传入的 model 的类型，遵守协议
 */
@property(nonatomic, strong) NSArray *dataSource;
/**
 *  YJCycleScrollViewNormalCell 的标题背景，默认白色
 */
@property(nonatomic, strong) UIColor *cellTitleBackgroundColor;
/**
 *  YJCycleScrollViewNormalCell 的标题的字体颜色，默认黑色
 */
@property(nonatomic, strong) UIColor *cellTitleTextColor;
/**
 *  当前未展示的其他 item 的分页指示符的颜色，默认 lightGrayColor
 */
@property(nonatomic, strong) UIColor *pageIndicatorTintColor;
/**
 *  当前展示页的分页指示符的颜色，默认 whiteColor
 */
@property(nonatomic, strong) UIColor *currentPageIndicatorTintColor;
/**
 *  代理
 */
@property(nonatomic, weak) id<YJCycleScrollViewDelegate> delegate;
/**
 *  item 的 size，默认宽为屏幕宽度，高为 50
 */
@property(nonatomic, assign) CGSize itemSize;
/**
 *  滚动的方向
 */
@property(nonatomic, assign) UICollectionViewScrollDirection scrollDirection;
/**
 *  item 之间的间隔
 */
@property(nonatomic, assign) CGFloat itemLineSpacing;
/**
 *  是否自动滚动，默认自动
 */
@property(nonatomic, assign) BOOL autoScroll;
/**
 *  自动滚动的间隔时间
 */
@property(nonatomic, assign) NSTimeInterval autoScrollTimeInterval;
/**
 *  使用 YJCycleScrollViewNormalCell 作为 cell 时，控制显示内容的枚举
 */
@property(nonatomic, assign) YJCycleScrollViewNormalCellContentType cellContentType;
/**
 *  是否显示分页指示符，默认显示
 */
@property(nonatomic, assign) BOOL showPageControl;
/**
 *  分页指示符的位置，默认 YJCycleScrollViewPageControlLocationBottomCenter
 */
@property(nonatomic, assign) YJCycleScrollViewPageControlLocation pageControlLocation;
/**
 *  分页指示符距离屏幕的距离，默认 (top: 0, left: 10, bottom: 10, right: 10)
 *  例如：
 *   结合 YJCycleScrollViewPageControlLocationBottomCenter 使用，分页指示符的位置就是居中，距离底部的距离为 10
 *   结合 YJCycleScrollViewPageControlLocationBottomLeft 使用，分页指示符的位置就是居左，距离父视图左边的距离为 10，底部的距离为 10
 */
@property(nonatomic, assign) UIEdgeInsets pageControlInsets;

@end

@protocol YJCycleScrollViewDelegate <NSObject>
@optional
/**
 *  如果需要自定义轮播图控件中展示的 cell 的类型，可以实现此方法。不实现则使用默认的 YJCycleScrollViewNormalCell
 *
 *  方法的实现中使用 UICollectionView 的 [registerClass:forCellWithReuseIdentifier:] 等类似方法即可，如果实现此方法，建议也将协议内的 [yj_innerCollectionView:acquireCellForItemAtIndexPath:] 方法实现
 *
 *  @param innerCollectionView 内部使用的 collectionView
 */
- (void)yj_registerCellClassForInnerCollectionView:( UICollectionView * _Nonnull )innerCollectionView;

/**
 *  如果需要自定义轮播图控件中展示的 cell 的赋值过程，可以实现此方法
 *
 *  @param innerCollectionView 内部使用的 collectionView
 *  @param indexPath           cell 的索引
 *
 *  @return UICollectionViewCell
 */
- (UICollectionViewCell * _Nonnull)yj_innerCollectionView:(UICollectionView * _Nonnull)innerCollectionView acquireCellForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

/**
 *  点击了 cell
 *
 *  @param cycleScrollView cycleScrollView
 *  @param indexPath       cell 的索引
 */
- (void)yj_cycleScrollView:(YJCycleScrollView * _Nonnull)cycleScrollView didSelectItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

/**
 *  确定 cell 中图片的下载方式
 *
 *  如果在 [yj_innerCollectionView:acquireCellForItemAtIndexPath:] 方法实现中有类似的实现步骤，可以不实现此方法。此方法主要针对默认的有图片展示时的 YJCycleScrollViewNormalCell 的图片下载方式
 *
 *  @param imgView  图片展示控件
 *  @param imageUrl 图片地址
 */
- (void)yj_decideCellImageview:(UIImageView * _Nonnull)imgView downloadImageModeWithImageUrl:(NSString * _Nonnull)imageUrl;

- (void)yj_cycleScrollView:(YJCycleScrollView *)cycleScrollView didDisplayItemAtIndexPath:(NSIndexPath *)indexPath;

@end


@protocol YJCycleScrollViewCellDataSource <NSObject>
@optional
- (NSString *)yj_cycleScrollViewCellTitle;
- (NSString *)yj_cycleScrollViewCellImageUrl;
- (NSAttributedString *)yj_cycleScrollViewCellAttributedTitle;
@end

NS_ASSUME_NONNULL_END