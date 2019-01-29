//
//  IpoInfoCell.h
//  qmp_ios
//
//  Created by QMP on 2018/1/10.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompanyDetailModel.h"

@interface IpoInfoCell : UITableViewCell

@property(nonatomic,strong) NSArray *arr;
@property(nonatomic,strong) CompanyDetailModel *companyModel;
@property(nonatomic,strong) NSMutableDictionary *requetDict;

@end
