//
//  QMPActivityDetialCommentView.h
//  CommonLibrary
//
//  Created by QMP on 2019/1/11.
//  Copyright © 2019 WSS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class ActivityCommentModel;
@interface QMPActivityDetialCommentView : UIView
@property (nonatomic, copy) NSString *activityTicket;
- (void)show;
@property (nonatomic, copy) NSString *anonymous2;
@property (nonatomic, copy) NSString *degree2;
- (void)updateRoleShow;
@property (nonatomic, copy) void(^roleDidTap)(NSString *anonymous2, NSString *degree2);

@property (nonatomic, copy) void(^activityCommentPost)(ActivityCommentModel *model);
@end


@interface QMPActivityDetialCommentTextView : UITextView
@property (nonatomic, copy) NSString *placeholder;
@end
NS_ASSUME_NONNULL_END
