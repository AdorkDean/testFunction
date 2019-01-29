//
//  WechatUserInfo.h
//  QiMingPian
//
//  Created by qimingpian08 on 16/4/25.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WechatUserInfo : NSObject

@property (nonatomic,copy)NSString *userid;
@property (nonatomic,copy)NSString *unionid;
@property (nonatomic,copy)NSString *uuid;
@property (nonatomic,copy)NSString *person_id; //官方人物personid
@property (nonatomic,copy)NSString *person_role;//角色 cyz => 创业者 ；investor => 投资人；FA => FA ；specialist =>专家 ；media =>媒体 ; other => 其他
@property (nonatomic,copy)NSString *usercode; //QID
@property (nonatomic,copy)NSString *coin;
@property (nonatomic,copy)NSString *nickname;
@property (nonatomic,copy)NSString *company;
@property (nonatomic,copy)NSString *zhiwei;
@property (nonatomic,copy)NSString *headimgurl;//用户头像
@property (nonatomic,copy)NSString *desc;
@property (nonatomic,copy)NSString *wechat;
@property (nonatomic,copy)NSString *phone;
@property (nonatomic,copy)NSString *bind_phone;
@property (nonatomic,copy)NSString *email;
@property (nonatomic,copy)NSString *card;
@property (copy, nonatomic) NSString *scope;
@property (nonatomic,copy)NSString *user_type;
@property (nonatomic,copy)NSString *bind_flag; //是否绑定手机 0  1
@property (nonatomic,copy)NSString *claim_type; ///< 认领4状态  0未认领  1审核  2成功 3失败
@property (copy, nonatomic) NSString *vip; //会员说明
@property (nonatomic,copy)NSString *openid;
@property (nonatomic,copy)NSString *app_focus; //是否引导关注过

@property (nonatomic,copy)NSString *infor_order; //资讯menu

//记录未读count 刷新后更新，某些操作需要刷新
@property (nonatomic,copy)NSString *apply_count; //交换联系方式申请count
@property (nonatomic,copy)NSString *bp_count; //收到的BP count
@property (nonatomic,copy)NSString *exchange_card_count; //交换的名片 count
@property (nonatomic,copy)NSString *system_notification_count;   //系统通知 count
@property (nonatomic,copy)NSString *activity_notifi_count; // 互动提醒count


@property (nonatomic, copy) NSString *flower_name;

//new 2017-9-11
+ (instancetype)shared;  //从NSUserDefault文件中读取用户信息

- (void)save;  //修改后save就保存到了NSUserDefault文件中

- (void)clear; //清空数据


@end
