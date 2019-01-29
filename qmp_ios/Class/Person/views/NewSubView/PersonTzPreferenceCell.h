//
//  PersonTzPreferenceCell.h
//  qmp_ios
//
//  Created by QMP on 2018/6/30.
//  Copyright © 2018年 Molly. All rights reserved.
//人物投资偏好cell  投资偏好  和 主投阶段

#import <UIKit/UIKit.h>
#import "DetailTagsCell.h"
#import "TagsFrame.h"

@interface PersonTzPreferenceCell : UITableViewCell

@property(nonatomic,strong)TagsFrame *tagsFrame;
@property(nonatomic,copy)NSString *titleStr;
@property(nonatomic,strong)UIButton *editBtn;

+ (id)cellWithTableView:(UITableView *)tableView tagString:(NSString*)tagsString clickShrinkTag:(void(^)(BOOL isSpread,TagsFrame *tagFrame))didClickShrinkTag clickTag:(void(^)(NSString *tag))didClickTag;


@end
