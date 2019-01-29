//
//  NewsTableViewCell.h
//  qmp_ios
//
//  Created by Molly on 2016/11/9.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsModel.h"

@interface NewsTableViewCell : UITableViewCell

@property (strong, nonatomic) UIView *bottomLine;
@property (strong, nonatomic) UILabel *titleLbl;
@property (strong, nonatomic) NewsModel *newsModel;

@property (assign, nonatomic) BOOL firstRow;

+ (NewsTableViewCell *)cellWithTableView:(UITableView *)tableView;

@end
