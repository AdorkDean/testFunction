//
//  BPDeliverStatusModel.h
//  qmp_ios
//
//  Created by QMP on 2018/7/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "JSONModel.h"

@interface BPDeliverStatusModel : JSONModel
@property (nonatomic, copy) NSString<Optional> * person_id;
@property (nonatomic, copy) NSString<Optional> * bp_name;
@property (nonatomic, copy) NSString<Optional> * create_time;
@property (nonatomic, copy) NSString<Optional> * interest_flag;
@property (nonatomic, copy) NSString<Optional> * browse_status;
@property (nonatomic, copy) NSString<Optional> * name;
@property (nonatomic, copy) NSString<Optional> * claim_type;
@property (nonatomic, copy) NSString<Optional> * icon;
@property (nonatomic, copy) NSString<Optional> * company;
@property (nonatomic, copy) NSString<Optional> * zhiwei;
@end
