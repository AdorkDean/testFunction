//
//  PersonModel.h
//  qmp_ios
//
//  Created by QMP on 2017/11/6.
//  Copyright © 2017年 Molly. All rights reserved.
//人物 model，综合人物信息

#import "ZhiWeiModel.h"
#import "NewsModel.h"
#import "EducationExpModel.h"
#import "WinExperienceModel.h"

@protocol PersonTouziModel;
@protocol ZhiWeiModel;
@protocol NewsModel;
@protocol EducationExpModel;
@protocol WorkExprienceModel;
@protocol WinExperienceModel;

@interface PersonModel : JSONModel

@property (copy, nonatomic) NSString <Optional>*personId;
@property (copy, nonatomic) NSString <Optional>*person_id;
@property (copy, nonatomic) NSString <Optional>*uniq_hid;
@property (copy, nonatomic) NSString <Optional>*unionids;
@property (copy, nonatomic) NSString <Optional>*unionid; //不加密的unioid
@property (copy, nonatomic) NSString <Optional>*ticket; //人物uuid
@property (copy, nonatomic) NSString <Optional>*ticket_id; //人物uuid

@property (copy, nonatomic) NSString <Optional>*nickname;
@property (copy, nonatomic) NSString <Optional>*name;
@property (copy, nonatomic) NSString <Optional>*person_name;

@property (copy, nonatomic) NSString <Optional>*position;
@property (copy, nonatomic) NSString <Optional>*detail;
@property (copy, nonatomic) NSString <Optional>*short_url;
@property (copy, nonatomic) NSString <Optional>*ename;
@property (copy, nonatomic) NSString <Optional>*cardurl; //人物名片
@property (copy, nonatomic) NSString <Optional>*user_url; //人物名片

@property (copy, nonatomic) NSString <Optional>*icon;
@property (copy, nonatomic) NSString <Optional>*headimgurl;
@property (copy, nonatomic) NSString <Optional>*zhiwu;

@property (copy, nonatomic) NSString <Optional>*coin;
@property (copy, nonatomic) NSString <Optional>*usercode;
@property (copy, nonatomic) NSString <Optional>*company;
@property (copy, nonatomic) NSString <Optional>*jieshao;
@property (copy, nonatomic) NSString <Optional>*is_dimission;
@property (copy, nonatomic) NSString <Optional>*tags; //人物画像

@property (copy, nonatomic) NSNumber <Optional>*apply_type; //交换的类型，1、手机 2、微信 3、都交换了
@property (copy, nonatomic) NSNumber <Optional>*entrust_state; //委托联系状态  1:可以委托   2:委托成功  3：今日已委托
//人物详情
@property (copy, nonatomic) NSString <Optional>*claim_type; //是否可认领 0(初始状态) 1(审核中)  2(已认领) 3(认证失败)

@property (copy, nonatomic) NSString <Optional>*share_link; //分享url
@property (copy, nonatomic) NSString <Optional>*tzanli;

@property (copy, nonatomic) NSString <Optional>*xueli;

@property (copy, nonatomic) id <Optional>lingyu;

//人物库
@property (copy, nonatomic) NSString <Optional>*agency;  //机构
@property (copy, nonatomic) NSString <Optional>*zhiwei;  


//数组类型
@property (strong, nonatomic) NSArray <PersonTouziModel,Optional>*tzanli1;
@property (strong, nonatomic) NSArray <PersonTouziModel,Optional>*faanli;
@property (strong, nonatomic) NSArray <WinExperienceModel,Optional>*win_experience; //获奖经历
@property (strong, nonatomic) NSArray <ZhiWeiModel,Optional>*work_exp;
@property (strong, nonatomic) NSArray <EducationExpModel,Optional>*edu_exp;
@property (strong, nonatomic) NSArray <NewsModel,Optional>*person_news;
@property (strong, nonatomic) NSArray <Optional>*role;
//角色 cyz => 创业者 ；investor => 投资人；FA => FA ；specialist =>专家 ；media =>媒体 ; other => 其他

@property (copy, nonatomic) NSString <Optional> *tzr; //HT 添加 用户主搜索 用于标记投资人角色 0 不是，1投资人

@property (copy, nonatomic) id <Optional>jieduan;
@property (copy, nonatomic) NSString <Optional>*invest_flag;
@property (copy, nonatomic) NSString <Optional>*wx_icon;
@property (copy, nonatomic) NSString <Optional>*wechat;
@property (copy, nonatomic) NSString <Optional>*phone;
@property (copy, nonatomic) NSString <Optional>*email;

@property(nonatomic,copy) NSString <Optional>*match_reason;//搜索匹配理由
@property (nonatomic, strong) id <Optional>highlight;

//反馈
@property (copy, nonatomic) NSNumber <Optional>*isFeedback;
@end
