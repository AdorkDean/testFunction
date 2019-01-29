//
//  SearchCompanyTableViewCell.h
//  qmp_ios
//
//  Created by qimingpian08 on 16/11/1.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SearchCompanyModel;

@interface SearchCompanyTableViewCell : UITableViewCell
@property(nonatomic,strong) UIView* lineV;
-(void)refreshUI:(SearchCompanyModel *)model;

@end
