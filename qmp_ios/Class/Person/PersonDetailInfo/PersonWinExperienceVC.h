//
//  PersonWinExperienceVC.h
//  qmp_ios
//
//  Created by QMP on 2018/4/13.
//  Copyright © 2018年 Molly. All rights reserved.
// 获奖经历

#import "BaseViewController.h"
#import "PersonModel.h"
#import "OrganizeItem.h"
#import "CompanyDetailModel.h"

typedef NS_ENUM(NSInteger, ExperionStyle){
    ExperionStylePerson = 1,  //从人物进入获奖经历列表
    ExperionStyleJiGou, //从机构进入获奖经历列表
    ExperionStylePro //从机构进入获奖经历列表

};

@interface PersonWinExperienceVC : BaseViewController

@property (nonatomic, copy) NSString * navTitleStr;
@property(nonatomic,strong)NSMutableArray *listArr;
@property(nonatomic,strong) PersonModel *person;
@property(nonatomic,strong) OrganizeItem *jigModel;
@property(nonatomic,strong) CompanyDetailModel *productM;

@property (nonatomic, assign) ExperionStyle formType; //从来哪儿进入获奖经历

@end
