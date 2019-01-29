//
//  ProductRongziCell.h
//  qmp_ios
//
//  Created by QMP on 2018/7/26.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompanyDetailRongziModel.h"
#import <TTTAttributedLabel.h>


@interface ProductRongziCell : UITableViewCell

@property (strong, nonatomic) TTTAttributedLabel *tzrLab;
@property (strong, nonatomic) TTTAttributedLabel *faLbl;
@property (strong, nonatomic) UIButton *sourceBtn;
@property (strong, nonatomic) UIView *lineView;
@property(nonatomic,assign) BOOL firstRow;
@property(nonatomic,assign) BOOL lastRow;

- (void)initData:(CompanyDetailRongziModel *)model;

@end
