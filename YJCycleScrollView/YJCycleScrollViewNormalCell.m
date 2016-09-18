//
//  YJCycleScrollViewNormalCell.m
//  YJCycleScrollView
//
//  Created by Jet on 16/9/2.
//  Copyright © 2016年 Jet. All rights reserved.
//

#import "YJCycleScrollViewNormalCell.h"

static CGFloat kTitleLabelHeight = 25;

@implementation YJCycleScrollViewNormalCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self.contentView addSubview:imgView];
    _imgView = imgView;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor redColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    [self.contentView addSubview:titleLabel];
    _titleLabel = titleLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
        
    CGFloat selfHeight = CGRectGetHeight(self.bounds);
    CGFloat selfWidth = CGRectGetWidth(self.bounds);
    switch (_contentType) {
        case YJCycleScrollViewNormalCellContentTypeBoth: {
            _imgView.hidden = NO;
            _titleLabel.hidden = NO;
            
            _imgView.frame = self.bounds;
            _titleLabel.frame = CGRectMake(0, selfHeight - kTitleLabelHeight, selfWidth, kTitleLabelHeight);
            break;
        }
            
        case YJCycleScrollViewNormalCellContentTypeOnlyImage: {
            _imgView.hidden = NO;
            _titleLabel.hidden = YES;
            
            _imgView.frame = self.bounds;
            break;
        }
            
            
        case YJCycleScrollViewNormalCellContentTypeOnlyTitle: {
            _imgView.hidden = YES;
            _titleLabel.hidden = NO;
            
            _titleLabel.frame = CGRectMake(0, 0, selfWidth, selfHeight);
            break;
        }
    }
}

@end
