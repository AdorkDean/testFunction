//
//  FeedbackDetailViewControlerViewController.h
//  qmp_ios
//
//  Created by qimingpian10 on 2016/11/7.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackDetailViewControlerViewController : BaseViewController

@property (copy, nonatomic) void(^beginEdit)(void);
@property (nonatomic,copy)NSString *searchStr;//搜索内容
@property (nonatomic,assign)NSInteger resultCount;//线索

@property (nonatomic,copy)NSString *from;

@end
