//
//  ActivityNotifiCell.h
//  qmp_ios
//
//  Created by QMP on 2018/9/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityNotifiModel:NSObject

@property (strong, nonatomic) NSDictionary *user_info;
@property (strong, nonatomic) NSDictionary *activity;

@property (copy, nonatomic) NSString *comment;
@property (copy, nonatomic) NSString *send_time;
@property (copy, nonatomic) NSString *coin;
@property (copy, nonatomic) NSString *anonymous;
@property (copy, nonatomic) NSString *send_type;
@property (copy, nonatomic) NSAttributedString *commentAttributeText;
@property (copy, nonatomic) NSAttributedString *activityAttributeText;


/** 动态推送类型 */
@property (assign, nonatomic) ActivityPushType pushType;
@property(nonatomic,assign) CGFloat commentContentHeight;
@property(nonatomic,assign) CGFloat activityContentHeight;
@property(nonatomic,assign) CGFloat totalHeight;


@end


@interface ActivityNotifiCell : UITableViewCell
@property(nonatomic,strong) ActivityNotifiModel *activityNofiModel;
+ (instancetype)cellWithTableView:(UITableView*)tableView;

@end
