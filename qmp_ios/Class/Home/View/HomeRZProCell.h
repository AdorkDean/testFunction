//
//  HomeProductCell.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2017/12/1.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CommonLibrary/RZNewsModel.h>
#import <CommonLibrary/SearchCompanyModel.h>

@interface HomeRZProCell : UITableViewCell

@property(nonatomic,strong)RZNewsModel *newsModel;

@property(nonatomic,strong) UIColor *iconColor;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property(nonatomic,strong)SearchCompanyModel *companyM;

@end
