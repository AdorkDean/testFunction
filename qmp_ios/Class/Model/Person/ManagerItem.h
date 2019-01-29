//
//  ManagerItem.h
//  qmp_ios
//
//  Created by Molly on 2016/11/28.
//  Copyright © 2016年 Molly. All rights reserved.
//  公司、机构团队

#import <Foundation/Foundation.h>

@interface ManagerItem : JSONModel

@property (copy, nonatomic) NSString <Optional>*personId;
@property (copy, nonatomic) NSString <Optional>*person_id;

@property (copy, nonatomic) NSString <Optional>*unionids;

@property (copy, nonatomic) NSString <Optional>*claim_type;
@property (copy, nonatomic) NSString <Optional>*name;
@property (copy, nonatomic) NSString <Optional>*ename; //昵称
@property (copy, nonatomic) NSString <Optional>*jieshao;
@property (copy, nonatomic) NSString <Optional>*icon;
@property (copy, nonatomic) NSString <Optional>*zhiwu;
@property (copy, nonatomic) NSString <Optional>*is_dimission;

@property (copy, nonatomic) NSString <Optional>*usercode;
@property (copy, nonatomic) NSString <Optional>* card_status; //0 不可交换  1允许交换  2 交换中 3交换成功
@property (copy, nonatomic) NSString <Optional>* is_friend;
//0、非认领用户 1、是好友关系 2、用户添加了人物好友，已申请 3、人物添加了用户， 同意添加 4、不是好友  5、非认证 交换中
@property (copy, nonatomic) NSString <Optional>* is_adviser; //融资顾问

@property(nonatomic,strong) NSNumber <Optional>*isPreciseFeedback;//是否信息准确 反馈,点击的话为@"yes",未点击为nil或@""
@property(nonatomic,strong) NSNumber <Optional>*isOverallFeedback;//是否信息全面 反馈,点击的话为@"yes",未点击为nil或@""


@property (nonatomic, copy) NSString <Optional>*person_type; ///< 1: Fa
@end
