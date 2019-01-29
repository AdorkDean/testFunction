//
//  MainNavViewController.h
//  QimingpianSearch
//
//  Created by Molly on 16/7/25.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainNavViewController : UINavigationController

/**
 *  蒙版view
 */
@property(nonatomic,strong) UIView *covreView;
/**
 *  是否 可以 滑动返回
 */
@property (nonatomic,assign) BOOL canDragBack;

@property (nonatomic, weak) UIView *grayLine;
@end
