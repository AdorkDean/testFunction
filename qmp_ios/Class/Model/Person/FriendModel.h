//
//  FriendModel.h
//  qmp_ios
//
//  Created by QMP on 2017/11/7.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface FriendModel : JSONModel

@property (copy, nonatomic) NSString <Optional>*coin;
@property (copy, nonatomic) NSString <Optional>*nickname;
@property (copy, nonatomic) NSString <Optional>*icon;

@property (copy, nonatomic) NSString <Optional>*company;//项目名字
@property (copy, nonatomic) NSString <Optional>*companyName;//公司名字
@property (copy, nonatomic) NSString <Optional>*headimgurl;

@property (copy, nonatomic) NSString <Optional>*unionids;
@property (copy, nonatomic) NSString <Optional>*person_id;
@property (copy, nonatomic) NSString <Optional>*ticket;
@property (copy, nonatomic) NSString <Optional>*detail_link; //公司
@property (copy, nonatomic) NSString <Optional>*detail; //公司
/** 1交换了电话 2交换了微信 3手机微信都交换了*/
@property (copy, nonatomic) NSString <Optional>*type;  //私信交换的类型

@property (copy, nonatomic) NSString <Optional>*usercode;

@property (copy, nonatomic) NSString <Optional>*vip;

@property (copy, nonatomic) NSString <Optional>*zhiwei;
@property (copy, nonatomic) NSString <Optional>*position;
@property (copy, nonatomic) NSString <Optional>*is_friend;
@property (copy, nonatomic) NSString <Optional>*phone;
@property (copy, nonatomic) NSString <Optional>*bind_phone;
@property (copy, nonatomic) NSString <Optional>*email;
@property (copy, nonatomic) NSString <Optional>*wechat;

//推荐好友
@property (copy, nonatomic) NSString <Optional>*name;
@property (copy, nonatomic) NSString <Optional>*personid;
@property (copy, nonatomic) NSString <Optional>*unionid;
@property (copy, nonatomic) NSString <Optional>*selected;



@property (copy, nonatomic) NSString <Optional>*exPhoneStatus;
@property (copy, nonatomic) NSString <Optional>*exWechatStatus;
@property (copy, nonatomic) NSString <Optional>*exPhoneStatus2;
@property (copy, nonatomic) NSString <Optional>*exWechatStatus2;
@end
