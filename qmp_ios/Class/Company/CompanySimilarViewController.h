//
//  CompanySimilarViewController.h
//  qmp_ios
//
//  Created by Molly on 2016/12/17.
//  Copyright © 2016年 Molly. All rights reserved.
// 项目 相似项目 

#import <UIKit/UIKit.h>
#import "CompanyDetailBasicModel.h"

typedef void(^RefreshCompanySimilarInfoBlock)(NSMutableArray *tableData);

@interface CompanySimilarViewController : BaseViewController
@property (strong, nonatomic) NSMutableArray *tagArr;
@property (strong, nonatomic) NSMutableDictionary *requestDict;

@property (strong, nonatomic) CompanyDetailBasicModel *companyItem;//公司基本信息
@property (nonatomic, copy) RefreshCompanySimilarInfoBlock refreshCompanySimilarInfoBlock;

@end
