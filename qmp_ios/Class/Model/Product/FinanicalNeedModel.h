//
//  FinanicalNeedModel.h
//  qmp_ios
//
//  Created by QMP on 2018/4/19.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>

/**
 项目-融资需求 model
 */
@interface FinanicalNeedModel : JSONModel

@property (nonatomic, copy) NSString <Optional> *bili;
@property (nonatomic, copy) NSString <Optional> *bp;
@property (nonatomic, copy) NSString <Optional> *bp_file_id;
@property (nonatomic, copy) NSString <Optional> *bp_name;
@property (nonatomic, copy) NSString <Optional> *jgname;
@property (nonatomic, copy) NSString <Optional> *need_lunci;
@property (nonatomic, copy) NSString <Optional> *need_money;
@property (nonatomic, copy) NSString <Optional> *shares1;
@property (nonatomic, copy) NSString <Optional> *shares2;
@property (nonatomic, copy) NSString <Optional> *sponsor;
@property (nonatomic, copy) NSString <Optional> *sponsor_phone;
@property (nonatomic, copy) NSString <Optional> *sponsor_position;
@property (nonatomic, copy) NSString <Optional> *unit;
@property (nonatomic, copy) NSString <Optional> *bright_spot;

@end
