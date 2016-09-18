//
//  YJCycleScrollViewNormalCell.h
//  YJCycleScrollView
//
//  Created by Jet on 16/9/2.
//  Copyright © 2016年 Jet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YJCycleScrollViewNormalCellContentType) {
    YJCycleScrollViewNormalCellContentTypeOnlyTitle = 1,
    YJCycleScrollViewNormalCellContentTypeOnlyImage,
    YJCycleScrollViewNormalCellContentTypeBoth,
};

@interface YJCycleScrollViewNormalCell : UICollectionViewCell
@property(nonatomic, weak, readonly) UILabel *titleLabel;
@property(nonatomic, weak, readonly) UIImageView *imgView;
@property(nonatomic, assign) YJCycleScrollViewNormalCellContentType contentType;
@end


