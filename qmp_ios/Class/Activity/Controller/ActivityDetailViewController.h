//
//  ActivityDetailViewController.h
//  qmp_ios
//
//  Created by QMP on 2018/6/28.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"
@class ActivityModel, ActivityRelateModel;
@interface ActivityDetailViewController : BaseViewController
@property (nonatomic, strong) NSString *activityID;
@property (nonatomic, strong) NSString *activityTicket;
@property (nonatomic, assign) BOOL community;
@property (nonatomic, strong) ActivityRelateModel *relateModel;

@property (nonatomic, copy) void(^activityCountChanged)(ActivityModel *activity);
@property (nonatomic, copy) void(^activityDidDeleted)(void);
@property (nonatomic, copy) void(^activityFocusChange)(ActivityModel *activity);

@property (nonatomic, assign) BOOL autoShowCommentInput;
/** 来自我的发布 */
@property(nonatomic,assign) BOOL fromMyActivityList;
@end
