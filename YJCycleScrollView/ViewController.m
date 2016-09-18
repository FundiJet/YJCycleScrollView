//
//  ViewController.m
//  YJCycleScrollView
//
//  Created by Jet on 16/9/2.
//  Copyright © 2016年 Jet. All rights reserved.
//

#import "ViewController.h"
#import "YJCycleScrollView.h"
#import "TestModel.h"

@interface ViewController () <YJCycleScrollViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    YJCycleScrollView *view = [[YJCycleScrollView alloc] init];
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    view.frame = CGRectMake(0, 80, screenWidth, 50);
    [self.view addSubview:view];
//    view.itemLineSpacing = 25;
    view.cellContentType = YJCycleScrollViewNormalCellContentTypeOnlyTitle;
    view.scrollDirection = UICollectionViewScrollDirectionVertical;
    view.itemSize = CGSizeMake(375, 50);
    view.delegate = self;
    view.showPageControl = NO;
//    view.autoScroll = NO;
    NSMutableArray *arr = @[].mutableCopy;
    for (int i = 0; i < 5; ++i) {
        TestModel *model = [TestModel new];
        model.name = [NSString stringWithFormat:@"【%d】", i];
        [arr addObject:model];
    }
    view.dataSource = arr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)yj_cycleScrollView:(YJCycleScrollView *)cycleScrollView didDisplayItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%ld", (long)indexPath.row);
}

@end
