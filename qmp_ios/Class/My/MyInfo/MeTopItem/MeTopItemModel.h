//
//  MeTopItemModel.h
//  qmp_ios
//
//  Created by QMP on 2018/5/17.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "JSONModel.h"

@interface MeTopItemModel : JSONModel

@property (nonatomic) NSString <Optional> * attentionId;
@property (nonatomic) NSString <Optional> * icon;
@property (nonatomic) NSString <Optional> * claim_type;
@property (nonatomic) NSString <Optional> * detail;

@property (nonatomic) NSString <Optional> * type;

@property (nonatomic) NSString <Optional> * project;
@property (nonatomic) NSString <Optional> * project_id;
@property (nonatomic) NSString <Optional> * ticket;
@property (nonatomic) NSString <Optional> * ticket_id; //ticket的加密

@property (nonatomic) NSString <Optional> * display_flag; //是否关注 1:关注（默认为空）  0:未关注
//关注项目
@property (nonatomic) NSString <Optional> * product;
@property (nonatomic) NSString <Optional> * yewu;
@property (nonatomic) NSString <Optional> * lunci;
//关注机构
@property (nonatomic) NSString <Optional> * name;
@property (nonatomic) NSString <Optional> * miaoshu;

//关注人物
@property (nonatomic) NSString <Optional> * position;
@property (nonatomic) NSString <Optional> * company;
@property (nonatomic) NSString <Optional> * nickname;

@property (nonatomic) NSString <Optional> * isAttetionItem;

@end
