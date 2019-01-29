//
//  ActivityCommentViewCell.h
//  qmp_ios
//
//  Created by QMP on 2018/7/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ActivityCommentModel;
@interface ActivityCommentViewCell : UITableViewCell
+ (ActivityCommentViewCell *)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) ActivityCommentModel *comment;
@property (nonatomic, strong) NSString *activityID;

@property (nonatomic, strong) UIImageView *lineView;
@property (copy, nonatomic) void(^didDeletedComment)(void);
@property (copy, nonatomic) void(^didLikeComment)(BOOL likeStatus);

@end

extern CGFloat const ActivityNoCommentViewCellHeight;
@interface ActivityNoCommentViewCell : UITableViewCell
+ (ActivityNoCommentViewCell *)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) UILabel *messageLabel;

@end
