//
//  ActiveJigouModel.h
//  qmp_ios
//
//  Created by QMP on 2017/11/9.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface Product :JSONModel

@property (copy, nonatomic) NSString <Optional>*product;
//@property (copy, nonatomic) NSString  <Optional>*detail;

@end


@protocol Product;

@interface ActiveJigouModel : JSONModel

@property (copy, nonatomic) NSString <Optional>*name;
@property (copy, nonatomic) NSString <Optional>*count;
@property (copy, nonatomic) NSString <Optional>*num;

//@property (copy, nonatomic) NSString <Optional>*jigou_name;
//
//@property (copy, nonatomic) NSString <Optional>*tz_count;
@property (copy, nonatomic) NSString <Optional>*detail;
@property (copy, nonatomic) Product <Optional>*product;

@property (copy, nonatomic) NSString <Optional>*icon;
//@property (copy, nonatomic) NSString <Optional>*miaoshu;

@property (copy, nonatomic) NSString <Optional>*agency_name;
//@property (copy, nonatomic) NSString <Optional>*touzi_count;
//@property (copy, nonatomic) NSString <Optional>*jigou_url;
//@property (nonatomic) NSArray <Company,Optional>*company;

@end
