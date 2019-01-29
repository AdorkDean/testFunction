//
//  StarProductsModel.h
//  qmp_ios
//
//  Created by qimingpian08 on 16/10/17.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StarProductsModel : JSONModel

//@property(nonatomic,assign) int typeNum;

@property(nonatomic,copy) NSString <Optional>*type;
@property(nonatomic,copy) NSString <Optional>* name;
@property(nonatomic,copy) NSString <Optional>* detail;
@property(nonatomic,copy) NSString <Optional>* icon;
@property(nonatomic,copy) NSString <Optional>* opentime;
@property(nonatomic,copy) NSString <Optional>* create_time;
@property(nonatomic,copy) NSString <Optional>* yewu;
@property(nonatomic,copy) NSString <Optional>* province;
@property(nonatomic,copy) NSString <Optional>* jieduan;
@property(nonatomic,copy) NSString <Optional>* hangye;
@property(nonatomic,copy) NSString <Optional>* renzheng;
@property(nonatomic,copy) NSString <Optional>* city;
@property(nonatomic,copy) NSString <Optional>* hangye1;
@property(nonatomic,copy) NSString <Optional>* hangye2;
@property(nonatomic,copy) NSString <Optional>* lunci;
@property(nonatomic,copy) NSString <Optional>* need_flag;
@property(nonatomic,copy) NSString <Optional>* product;
@property(nonatomic,copy) NSString <Optional>* tags_match;
@property(nonatomic,copy) NSString <Optional>* tags_unmatch;

@property(nonatomic,copy) NSString <Optional>*company;
@property(nonatomic,copy) NSString <Optional>*curlunci;
@property(nonatomic,copy) NSString <Optional>*company_faren;


@property(nonatomic,copy) NSString <Optional>*productId;
@property(nonatomic,copy) NSString <Optional>*open_time;
@property (strong, nonatomic) NSString <Optional>*need_rongzi;

@property(nonatomic,copy) NSString <Optional>*desc;
@property(nonatomic,copy) NSString <Optional>*tuijian;
@property(nonatomic,copy) NSString <Optional>*time;
@property (assign, nonatomic) NSString <Optional>*selected;


//融资需求
@property (strong, nonatomic) NSString <Optional>*need_lunci;
@property(nonatomic,copy) NSString <Optional>* need_money;
@property(nonatomic,copy) NSString <Optional>* unit;

// BP
@property (nonatomic, strong) NSString <Optional> *bp_file_id;
@property (nonatomic, strong) NSString <Optional> *bp_name;
@end
