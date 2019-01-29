//
//  SearchDetailViewController.h
//  QiMingPian
//
//  Created by qimingpian08 on 16/4/28.
//  Copyright © 2016年 qimingpian. All rights reserved.

// 搜索页面  公司 结构，（首页搜索点击就是进入这个）

#import <UIKit/UIKit.h>

typedef void(^SearchBlock) (NSString *searchStr);

@interface SearchDetailViewController : BaseViewController

@property (nonatomic,copy)NSString *searchString;//搜索内容
@property (nonatomic,strong)NSDictionary *searchDict;//搜索内容的参数

@property (nonatomic ,copy) SearchBlock searchBlock;

@end
