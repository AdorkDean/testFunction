//
//  WorkExprienceModel.h
//  qmp_ios
//
//  Created by QMP on 2017/11/7.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>

/*
 desc = "";
 detail = "http://qimingpian.com/page/detailorg.html?src=magic&ticket=3021&id=6dbedc1f9a0c55b5578b5912d51c7d94";
 "end_time" = "";
 icon = "http://img.798youxi.com/product/upload/57bebacc57f93.png";
 id = 1740;
 "is_dimission" = 0;
 "jigou_id" = 1740;
 name = "\U6668\U5174\U8d44\U672c";
 product = "\U6668\U5174\U8d44\U672c";
 "start_time" = "";
 type = jigou;
 "work_num" = 0;
 zhiwu = "\U521b\U59cb\U5408\U4f19\U4eba&\U8463\U4e8b\U603b\U7ecf\U7406";
 */

@interface WorkExprienceModel : JSONModel

@property (copy, nonatomic) NSString <Optional>*workExpId;
@property (copy, nonatomic) NSString <Optional>*detail;
@property (copy, nonatomic) NSString <Optional>*desc;

@property (copy, nonatomic) NSString <Optional>*icon;
@property (strong, nonatomic) NSNumber <Optional>*is_dimission;
@property (copy, nonatomic) NSString <Optional>*company;
@property (copy, nonatomic) NSString <Optional>*jigou_id;
@property (copy, nonatomic) NSString <Optional>*name;
@property (copy, nonatomic) NSString <Optional>*product;
@property (copy, nonatomic) NSString <Optional>*zhiwu;

@property (copy, nonatomic)NSString <Optional> *start_time;
@property (copy, nonatomic)NSString <Optional> *end_time;


@end
