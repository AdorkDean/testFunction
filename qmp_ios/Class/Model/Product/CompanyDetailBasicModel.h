//
//  CompanyDetailBasicModel.h
//  QimingpianSearch
//
//  Created by qimingpian08 on 16/5/5.
//  Copyright © 2016年 qimingpian. All rights reserved.
//
/*
 * 公司详情 基本信息+联系方式
 */
#import <Foundation/Foundation.h>
#import "CompanyDetailLianxiModel.h"

@protocol CompanyDetailRongziModel; //融资历史
@protocol CompanyDetailLianxiModel;
@protocol ManagerItem;

@interface CompanyDetailBasicModel : JSONModel

//企名片为例
@property(nonatomic,copy) NSString <Optional>* product_id;//北京棱镜魔方科技有限公司 全称
@property(nonatomic,copy) NSString <Optional>* company;//北京棱镜魔方科技有限公司 全称
@property(nonatomic,copy) NSString <Optional>* province;//北京
@property(nonatomic,copy) NSString <Optional>* detail;//用于跳转参数
@property(copy,nonatomic) NSString<Optional>*share_link; //分享链接
@property(nonatomic,copy) NSString <Optional>* detailm;//
@property(nonatomic,copy) NSString <Optional>* detailwx;//
@property(nonatomic,copy) NSString <Optional>* open_time;//2015-12-07
@property(nonatomic,copy) NSString <Optional>* orderbyopentime;//20151207
@property(nonatomic,copy) NSString <Optional>* country;//CN
@property(nonatomic,copy) NSString <Optional>* faren;//党壮
@property(nonatomic,copy) NSString <Optional>* company_ziben;//235.2941万元人民币
@property(nonatomic,copy) NSString <Optional>*faren_id;
@property(nonatomic,copy) NSString <Optional>*legal_hid; //法人id
@property(nonatomic,copy) NSString <Optional>*cid;
@property(nonatomic,copy) NSString <Optional>* icon;//
@property(nonatomic,copy) NSString <Optional>* product;//企名片简称
@property(nonatomic,copy) NSString <Optional>* gw_link;//
@property(copy,nonatomic) NSArray <Optional> *tags_portrait;
@property(copy,nonatomic) NSString <Optional> *tags;
@property(nonatomic,copy) NSString <Optional>* miaoshu;//简介..
@property(nonatomic,copy) NSString <Optional>* hangye1;//企业服务
@property(nonatomic,copy) NSString <Optional>* hangye2;//数据服务
@property(nonatomic,copy) NSString <Optional>* yewu;//普惠企业大数据
@property(nonatomic,strong)NSNumber <Optional> *renzheng;//1
//@property(nonatomic,copy) NSString <Optional>* curlunci;//种子轮
@property(nonatomic,copy) NSString <Optional>* lunci;//种子轮
@property(nonatomic,copy) NSString <Optional>* work_flow;//种子轮

//@property(nonatomic,strong) NSArray <CompanyDetailRongziModel,Optional>* rongzi;//融资历史
//@property(nonatomic,strong)CompanyDetailLianxiModel <Optional>* lianXI;//联系方式

//@property(nonatomic,copy) NSString <Optional>*phone_number;//联系电话
//@property(nonatomic,copy) NSString <Optional>*email; //   联系邮箱
//@property(nonatomic,copy) NSString <Optional>*qy_reg_address; //注册地址
@property(nonatomic,copy) NSString <Optional>*qy_no; //注册号
@property(nonatomic,copy) NSString <Optional>*org_number; //组织机构代码
@property(nonatomic,copy) NSString <Optional>*qy_belong; //登记机关
@property(nonatomic,copy) NSString <Optional>*qy_type; //公司类型
@property(nonatomic,copy) NSString <Optional>*qy_status; //经营状态

@property(nonatomic,copy) NSString <Optional>* orderbyrztime;//20160216
@property(nonatomic,copy) NSString <Optional>* rztime;//2016.2.16
@property(nonatomic,strong) NSNumber <Optional>*isvie;//0
@property(nonatomic,copy) NSString <Optional>* vie;//
@property(nonatomic,strong) NSNumber <Optional>*follow;//0
@property(nonatomic,copy) NSString <Optional>*companyId;

@property (nonatomic, copy) NSString <Optional>*valuations_money;//估值 0729 molly
@property (nonatomic, copy) NSString <Optional>*valuations_time;
@property (nonatomic, copy) NSString <Optional>*need_flag;//是否融资中

@property (nonatomic, copy) NSString <Optional>*ziben_jieduan;//上市类型
@property (nonatomic, copy) NSString <Optional>*code;//股票代码

@property(nonatomic,strong) NSArray <Optional>*allipo; //多板块信息

@property(nonatomic,copy) NSString <Optional>*short_url;//短链接
@property(nonatomic,copy) NSString <Optional>*claim_unionid; //项目认领人unionid

@end
