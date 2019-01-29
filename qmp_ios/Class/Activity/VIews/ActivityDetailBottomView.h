//
//  ActivityDetailBottomView.h
//  qmp_ios
//
//  Created by QMP on 2018/7/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ActivityModel, ActivityCommentModel;
@interface ActivityDetailBottomView : UIView
@property (nonatomic, strong) NSString *activityID;
@property (nonatomic, strong) NSString *activityTicket;
@property (nonatomic, strong) ActivityModel *activity;

@property (nonatomic, copy) void(^activityValueChanged)(void);
@property (nonatomic, copy) void(^activityCommentPost)(ActivityCommentModel *model);
- (void)commentButtonClick;
@end

@interface ActivityDetailCommentView : UIView
@property (nonatomic, strong) NSString *activityID;
@property (nonatomic, strong) NSString *activityTicket;
@property (nonatomic, assign) CGFloat defaultHeight;
@property (nonatomic, strong) ActivityModel *activity;

@property (nonatomic, assign) BOOL anonymous;
@property (nonatomic, copy) void(^activityValueChanged)(void);

@property (nonatomic, copy) void(^activityCommentPost)(ActivityCommentModel *model);
- (void)show;

- (void)autoAnonymous;
@end
