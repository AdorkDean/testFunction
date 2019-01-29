//
//  QMPActivityCellManager.h
//  qmp_ios
//
//  Created by QMP on 2018/8/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

//@protocol QMPActivityCellDelegate;
#import "QMPActivityCell.h"
@interface QMPActivityCellManager : NSObject <QMPActivityCellDelegate>
+ (instancetype)manager;

@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *activities;
@property (nonatomic, assign) BOOL isCommunity;

@property (nonatomic, copy) void(^activityDidDeleled)(NSIndexPath *indexPath);
@property (nonatomic, copy) void(^activityDidChanged)(void);
@property (nonatomic, copy) void(^activityFocusChange)(ActivityModel *activityM);

- (void)doActionWithItem:(NSString *)item activity:(ActivityModel *)a;

- (void)removeMenuView;
@end


