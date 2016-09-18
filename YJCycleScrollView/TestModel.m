//
//  TestModel.m
//  YJCycleScrollView
//
//  Created by Jet Yan on 16/9/2.
//  Copyright © 2016年 Jet. All rights reserved.
//

#import "TestModel.h"
#import "YJCycleScrollView.h"

@interface TestModel ()<YJCycleScrollViewCellDataSource>

@end

@implementation TestModel
//- (NSString *)yj_cycleScrollViewCellTitle {
//    return _name;
//}

- (NSAttributedString *)yj_cycleScrollViewCellAttributedTitle {
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"Test"];
    
    NSDictionary *dict1 = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
                           NSForegroundColorAttributeName : [UIColor brownColor]};
    NSAttributedString *s1 = [[NSAttributedString alloc] initWithString:@"123" attributes:dict1];
    [str appendAttributedString:s1];
    
    NSDictionary *dict2 = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
                            NSForegroundColorAttributeName : [UIColor greenColor]};
    NSAttributedString *s2 = [[NSAttributedString alloc] initWithString:@"123" attributes:dict2];
    [str appendAttributedString:s2];
    
    return str.copy;
}

@end
