//
//  CompanyBasicInfoTableViewCell.h
//  qmp_ios
//
//  Created by Molly on 2016/12/15.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchButton.h"
#import "CopyLabel.h"
#import "CompanyDetailBasicModel.h"

@interface CompanyBasicInfoTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic) UILabel *infoLbl;
@property (strong, nonatomic) SearchButton *searchBtn;

@property(nonatomic,strong) CompanyDetailBasicModel *model;

- (void)initDataWithKey:(NSString *)key withValue:(NSString *)value;

- (void)dataWithKey:(NSString *)key withValue:(CompanyDetailBasicModel *)model;

@property (nonatomic, assign) BOOL justShowDesc;
@end
