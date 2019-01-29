//
//  ManagerSquareViewController.h
//  qmp_ios
//
//  Created by Molly on 16/9/5.
//  Copyright © 2016年 Molly. All rights reserved.
//专辑管理

#import <UIKit/UIKit.h>

@protocol ManagerSquareVCDelegate<NSObject>

@end

@interface ManagerSquareViewController : BaseViewController

@property (nonatomic, weak) id<ManagerSquareVCDelegate> delegate;
@property (strong, nonatomic) UISearchBar *mySearchBar;

- (void)disAppear;  //左右切换

- (void)beginSearch:(NSString*)text;
/** 榜单 专辑*/
@property(nonatomic,assign) BOOL isTop;

@end
