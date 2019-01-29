//
//  WinExperienceModel.h
//  qmp_ios
//
//  Created by QMP on 2018/4/13.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface WinExperienceModel : JSONModel

@property (copy, nonatomic) NSString <Optional>*awards; //颁奖人
@property (copy, nonatomic) NSString <Optional>*winExId; //获奖经历ID
@property (copy, nonatomic) NSString <Optional>*time;
@property (copy, nonatomic) NSString <Optional>*winning; //获奖经历

//项目机构的
@property (copy, nonatomic) NSString <Optional>*prize_name;
@property (copy, nonatomic) NSString <Optional>*prize_time;

@end
