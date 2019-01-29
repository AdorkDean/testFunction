//
//  SmarketEventModel.h
//  qmp_ios
//
//  Created by QMP on 2018/3/27.
//  Copyright © 2018年 Molly. All rights reserved.
//上市库model

#import <JSONModel/JSONModel.h>

@interface SmarketEventModel : JSONModel

@property (nonatomic, copy) NSString <Optional>*listing_time;
@property (nonatomic, copy) NSString <Optional>*shangshididian;
@property (nonatomic, copy) NSString <Optional>*hangye1;
@property (nonatomic, copy) NSString <Optional>*company;
@property (nonatomic, copy) NSString <Optional>*detail;
@property (nonatomic, copy) NSString <Optional>*product_id;
@property (nonatomic, copy) NSString <Optional>*shizhi;
@property (nonatomic, copy) NSString <Optional>*chinastock;
@property (nonatomic, copy) NSString <Optional>*ipo_type;
@property (nonatomic, copy) NSString <Optional>*ipo_code;
@property (nonatomic, copy) NSString <Optional>*ipo_short;
@property (nonatomic, copy) NSString <Optional>*bizhong;
@property (nonatomic, copy) NSString <Optional>*yewu;
@property (nonatomic, copy) NSString <Optional>*money;


//新三板
@property (nonatomic, copy) NSString <Optional>*icon;
@property (nonatomic, copy) NSString <Optional>*valuations_money;
@property (nonatomic, copy) NSString <Optional>*tags_match;
@property (nonatomic, copy) NSString <Optional>*sponsor; //保荐机构
@property (nonatomic, copy) NSString <Optional>*uuid;
@property (nonatomic, copy) NSString <Optional>*gujia;
//@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString <Optional>*is_latest;
@property (nonatomic, copy) NSString <Optional>*product;
@property (nonatomic, copy) NSString <Optional>*date;

@end
