//
//  SearchBindProController.h
//  qmp_ios
//
//  Created by QMP on 2017/12/29.
//  Copyright © 2017年 Molly. All rights reserved.

//评论    搜索要关联的项目， 显示搜索历史和关注的项目

#import "BaseViewController.h"
#import "SearchCompanyModel.h"


@interface SearchBindProController : BaseViewController

@property (copy, nonatomic) void (^selectedProduct)(SearchCompanyModel *company);

@end
