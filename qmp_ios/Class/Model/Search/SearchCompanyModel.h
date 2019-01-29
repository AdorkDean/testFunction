//
//  SearchCompanyModel.h
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/3.
//  Copyright © 2016年 qimingpian. All rights reserved.



#import <Foundation/Foundation.h>
#import <JSONModel.h>

@interface SearchCompanyModel : JSONModel

@property(nonatomic,copy) NSString <Optional>* company_id;//id
@property(nonatomic,copy) NSString <Optional>* company;
@property(nonatomic,copy) NSString <Optional>* province;
@property(nonatomic,copy) NSString <Optional>* detail;
@property(nonatomic,copy) NSString <Optional>* open_time;
@property(nonatomic,copy) NSString <Optional>* icon;
@property(nonatomic,copy) NSString <Optional>* product;
@property(nonatomic,copy) NSString <Optional>* gw_link;
@property(nonatomic,copy) NSString <Optional>* desc;
@property(nonatomic,copy) NSString <Optional>* hangye1;
@property(nonatomic,copy) NSString <Optional>* yewu;
@property(nonatomic,copy) NSString <Optional>* curlunci;
@property(nonatomic,copy) NSString <Optional>* lunci;
@property(nonatomic,copy) NSString <Optional>* money;
@property(nonatomic,copy) NSString <Optional>* time;


@property (nonatomic, copy) NSString <Optional>*productId;

@property(nonatomic,copy) NSString <Optional>* renzheng;
@property (nonatomic, copy) NSString <Optional>*need_flag;//是否融资中
@property(nonatomic,strong) NSArray <Optional>*allipo; //多板块信息

@property(nonatomic,copy) NSString <Optional>*short_url;//短链接
@property (strong, nonatomic) NSMutableDictionary <Optional>*detailMDict;

//项目库
@property (strong, nonatomic) NSArray <Optional>*investor_info;

//官方人物 投资案例 轮次
@property (copy, nonatomic) NSString <Optional>*tzLunci;

//工作流所需要的
//@property(nonatomic,copy) NSNumber <Optional>*work_flow;
@property(nonatomic,copy) NSString <Optional>*create_time;
@property(nonatomic,copy) NSString <Optional>*mark;
@property (nonatomic, copy) NSString <Optional>*selected;//工作流中是否选中, 0 1

@property (nonatomic, strong) NSNumber <Optional>*claim_type; ///< 认领状态 1:审核中 2:通过 3:拒绝
@property (nonatomic, strong) NSString <Optional>*claim_unionid; ///< 认领人ID
- (NSMutableDictionary *)handleDetailToDict;

@property(nonatomic,strong) NSNumber <Optional>*isFeedback;
@property (nonatomic, strong) id <Optional> highlight;
@end
