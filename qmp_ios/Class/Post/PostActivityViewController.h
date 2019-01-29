//
//  PostActivityViewController.h
//  qmp_ios
//
//  Created by QMP on 2018/6/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger,PostFrom){
    PostFrom_Circle = 1, //来自社区
    PostFrom_Detail,  //来自详情页
    PostFrom_Flash  //来自短讯
};


@class CompanyDetailModel, OrganizeItem, PersonModel;
@interface PostActivityViewController : BaseViewController
@property (nonatomic, strong) NSString *link_url;
@property (nonatomic, assign) BOOL autoAnonymous;
@property(nonatomic,assign)PostFrom postFrom;
@property (nonatomic, strong) CompanyDetailModel *company;
@property (nonatomic, strong) OrganizeItem *orgnize;
@property (nonatomic, strong) PersonModel *person;
@property (nonatomic, strong) id model;

@property (nonatomic, assign) BOOL needGo;
@property (nonatomic, copy) void(^postSuccessBlock)(void);
@end
