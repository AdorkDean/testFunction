//
//  WorkFlowToAlbumController.h
//  qmp_ios
//
//  Created by QMP on 2017/11/2.
//  Copyright © 2017年 Molly. All rights reserved.
//导入到专辑   从 工作流   专辑管理

#import "BaseViewController.h"
#import "TagsItem.h"

typedef void(^IntroductSuccess)(void);

@interface WorkFlowToAlbumController : BaseViewController
@property(nonatomic,strong) TagsItem *tag;
@property (copy, nonatomic) IntroductSuccess introductSuccess;
@property(nonatomic,strong) NSArray *companyIdArr;

@end
