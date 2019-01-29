//
//  QMPMyCommentCell.h
//  qmp_ios
//
//  Created by QMP on 2018/9/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QMPMyComment;
@interface QMPMyCommentCell : UITableViewCell
+ (QMPMyCommentCell *)myCommentCellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) QMPMyComment *comment;

@property (nonatomic, copy) void(^commentDidDeleted)(void);
@end


@interface QMPMyComment : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *like_num;

@property (nonatomic, copy) NSAttributedString *comment;
@property (nonatomic, copy) NSAttributedString *content;

- (instancetype)initWithCommentDict:(NSDictionary *)dict;


@property (nonatomic, assign) CGFloat textHeight;
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, assign) CGFloat cellHeight;


@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *activityID;
@property (nonatomic, copy) NSString *activityTicket;


@property (nonatomic, assign) BOOL didDeleted;
@end
