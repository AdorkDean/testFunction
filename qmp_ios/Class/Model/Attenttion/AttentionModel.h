//
//  AttentionModel.h
//  qmp_ios
//
//  Created by QMP on 2018/5/17.
//  Copyright © 2018年 Molly. All rights reserved.
//关注model   列表

#import "JSONModel.h"

@interface AttentionModel : JSONModel
@property (copy, nonatomic) NSString <Optional>*attentionId; // 新闻组 id
@property (copy, nonatomic) NSString <Optional>*type;
@property (copy, nonatomic) NSString <Optional>*user_type; //用户账户类型：官方-普通
@property (copy, nonatomic) NSString <Optional>*project;
@property (copy, nonatomic) NSString <Optional>*project_id; //项目机构领域的id
@property (copy, nonatomic) NSString <Optional>*detail; //项目或机构的detail
@property (copy, nonatomic) NSString <Optional>*display_flag; //0未关注 1已关注
@property (copy, nonatomic) NSString <Optional>*top_flag;
@property (copy, nonatomic) NSString <Optional>*unread_flag;
@property (copy, nonatomic) NSString <Optional>*click_time;
@property (copy, nonatomic) NSString <Optional>*object_time;
@property (copy, nonatomic) NSString <Optional>*icon;
@property (copy, nonatomic) NSString <Optional>*title;
@property (copy, nonatomic) NSString <Optional>*unread_count;
//人物
@property (copy, nonatomic) NSString <Optional>*zhiwei;
@property (copy, nonatomic) NSString <Optional>*company;



@end
