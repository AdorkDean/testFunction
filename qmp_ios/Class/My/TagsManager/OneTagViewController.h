//
//  OneTagViewController.h
//  qmp_ios
//
//  Created by molly on 2017/5/19.
//  Copyright © 2017年 Molly. All rights reserved.

//一个标签的页面

#import <UIKit/UIKit.h>

#import "TagsItem.h"

@protocol OneTagViewControllerDelegate <NSObject>

@optional
- (void)addSuccess:(TagsItem *)tagItem;
- (void)delSuccess:(TagsItem *)tagItem;

@end

@interface OneTagViewController : BaseViewController

@property (weak, nonatomic) id<OneTagViewControllerDelegate> delegate;

- (instancetype)initWithTagItem:(TagsItem *)tagItem;

@end
