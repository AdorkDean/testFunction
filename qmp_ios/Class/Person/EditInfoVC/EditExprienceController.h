//
//  EditExprienceController.h
//  qmp_ios
//
//  Created by QMP on 2018/1/29.
//  Copyright © 2018年 Molly. All rights reserved.
//新建  添加   工作和教育经历

#import "BaseViewController.h"
#import "ExperienceModel.h"
#import "ZhiWeiModel.h"
#import "EducationExpModel.h"

typedef NS_ENUM(NSInteger,FromView){
    FromView_CreatorPerson = 1, //来自创建人物
    FromView_PersonDetail
};

typedef void(^SaveSuccess)(id newExperienceM);
typedef void(^DelSuccess)(id newExperienceM);
typedef void(^BackToLatPage)(void);

@interface EditExprienceController : BaseViewController


@property(nonatomic,assign) BOOL isJob;
@property(nonatomic,assign) FromView fromView;
@property (copy, nonatomic) SaveSuccess saveInfoSuccess;
@property (copy, nonatomic) DelSuccess  delInfoSuccess;
@property (copy, nonatomic) BackToLatPage  backToLatPage;

@property(nonatomic,strong)id experienceM; //EducationExpModel 或者 ZhiWeiModel(详情)，ExperienceModel(创建人物)

@end
