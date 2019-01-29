//
//  CollectionListTableViewCell.h
//  QimingpianSearch
//
//  Created by Molly on 16/8/6.
//  Copyright © 2016年 qimingpian. All rights reserved.
//网页收藏cell

#import <UIKit/UIKit.h>
#import "URLModel.h"

@interface CollectionListTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *titleLbl;
@property (strong, nonatomic) UILabel *urlLbl;
@property (strong, nonatomic) UILabel *timeLbl;
@property (strong, nonatomic) UIButton *readBtn;

@property (strong, nonatomic) NSString *urlId;

- (void)initData:(URLModel *)urlModel;

@end
