//
//  OrganizeItem.h
//  qmp_ios
//
//  Created by Molly on 2016/11/28.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrganizeItem : JSONModel


@property (copy, nonatomic) NSString <Optional>*name;
@property (copy, nonatomic) NSString <Optional>*icon;
@property (copy, nonatomic) NSString <Optional>*found_year;
@property (copy, nonatomic) NSString <Optional>*gw_link;
@property (copy, nonatomic) NSString <Optional>*miaoshu;
@property (copy, nonatomic) NSString <Optional>*jg_type;
@property (copy, nonatomic) NSString <Optional>*ticket;


//需要
@property (copy, nonatomic) NSString <Optional>*score;        //战绩分数
@property (copy, nonatomic) NSString <Optional>*short_url;     //分享短链
@property (copy, nonatomic) NSString <Optional>*detail;
@property (copy, nonatomic) NSString <Optional>*combinetz_count; //参投
@property (copy, nonatomic) NSString <Optional>*togethertz_count; //合投

@property (nonatomic, strong) NSNumber <Optional>*claim_type; ///< 认领状态 1: 拒绝 2: 审核中 3: 通过
@property (nonatomic, strong) NSString <Optional>*claim_unionid; ///认领人

@property (copy, nonatomic) NSString <Optional>*fa_renzheng; ///< 0 不在服  1 在服
/**
1:可以委托   2:委托成功  3：今日已委托(失败或没结果)，明日可再委托
*/
@property (copy, nonatomic) NSString <Optional>*entrust_state; //
//other
@property (copy, nonatomic) NSString <Optional>*jigou_name;
@property (copy, nonatomic) NSString <Optional>*jianjie;
@property (copy, nonatomic) NSString <Optional>*tz_count;

@property (copy, nonatomic) NSString <Optional>*tzcount;

@property (copy, nonatomic) NSString <Optional>*faCasecount;

@end
