//
//  EducationExpModel.h
//  qmp_ios
//
//  Created by QMP on 2017/11/7.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>

/*"id": "c366c2c97d47b02b24c3ecade4c40a011886",
 "start_time": "",
 "end_time": "",
 "xueli": "\u5b66\u58eb",
 "school": "\u9999\u6e2f\u7406\u5de5\u5927\u5b66",
 "major": "\u5546\u4e1a\u5b66",
 "desc": "\u9999\u6e2f\u7406\u5de5\u5927\u5b66",
 "sort_num": "0"*/

@interface EducationExpModel : JSONModel

@property (copy, nonatomic) NSString <Optional>*educationId;
@property (copy, nonatomic) NSString <Optional>*start_time;
@property (copy, nonatomic) NSString <Optional>*end_time;
@property (copy, nonatomic) NSString <Optional>*xueli;
@property (copy, nonatomic) NSString <Optional>*school;
@property (copy, nonatomic) NSString <Optional>*major;
@property (copy, nonatomic) NSString <Optional>*desc;
@property (copy, nonatomic) NSString <Optional>*sort_num;

@end
