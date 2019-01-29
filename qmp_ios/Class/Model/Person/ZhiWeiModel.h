//
//  ZhiWeiModel.h
//  qmp_ios
//
//  Created by QMP on 2017/11/7.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface ZhiWeiModel : JSONModel
/**jigou product person  register other*/
@property (copy, nonatomic) NSString <Optional>*jump_type;

@property (copy, nonatomic) NSString <Optional>*zhiweiId;
@property (copy, nonatomic) NSString <Optional>*work_num;
@property (copy, nonatomic) NSString <Optional>*type;
@property (copy, nonatomic) NSString <Optional>*old_type;

@property (copy, nonatomic) NSString <Optional>*jigou_id;
@property (copy, nonatomic) NSString <Optional>*name;
@property (copy, nonatomic) NSString <Optional>*product;
@property (copy, nonatomic) NSString <Optional>*zhiwu;
@property (copy, nonatomic) NSString <Optional>*zhiwei;
@property (copy, nonatomic) NSString <Optional>*company;
@property (copy, nonatomic) NSString <Optional>*icon;
@property (copy, nonatomic) NSString <Optional>*is_dimission;
@property (copy, nonatomic) NSString <Optional>*detail;
@property (copy, nonatomic) NSString <Optional>*desc;
@property (copy, nonatomic)NSString <Optional> *start_time;
@property (copy, nonatomic)NSString <Optional> *end_time;

@end

