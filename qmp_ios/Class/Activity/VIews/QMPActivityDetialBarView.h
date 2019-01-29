//
//  QMPActivityDetialBarView.h
//  CommonLibrary
//
//  Created by QMP on 2019/1/11.
//  Copyright © 2019 WSS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class ActivityCommentModel;
@interface QMPActivityDetialBarView : UIView

@property (nonatomic, copy) NSString *activityTicket;
@property (nonatomic, copy) NSString *anonymous2;
@property (nonatomic, copy) NSString *degree2;
- (void)commentButtonClick;

@property (nonatomic, assign) BOOL showRole;
- (void)showRoleView;

@property (nonatomic, copy) void(^roleDidTap)(NSString *anonymous2, NSString *degree2);
@property (nonatomic, copy) void(^activityCommentPost)(ActivityCommentModel *model);
@end

@interface CommentPostRoleSelectView : UIView
@end


NS_ASSUME_NONNULL_END
