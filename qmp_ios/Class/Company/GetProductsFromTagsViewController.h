//
//  GetProductsFromTagsViewController.h
//  qmp_ios
//
//  Created by qimingpian10 on 2016/12/9.
//  Copyright © 2016年 Molly. All rights reserved.
// 标签详情页   点击产品详情的标签进入

#import <UIKit/UIKit.h>
#import "TagsFrame.h"

@interface GetProductsFromTagsViewController : BaseViewController

@property (nonatomic,strong) NSMutableDictionary *urlDict;
@property (nonatomic,assign) BOOL isMatchTag;

@end
