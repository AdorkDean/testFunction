//
//  SearchNewsCell.h
//  CommonLibrary
//
//  Created by QMP on 2018/12/17.
//  Copyright © 2018 WSS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface SearchNewsCell : UITableViewCell

@property (strong, nonatomic) UIView *bottomLine;
@property (strong, nonatomic) NewsModel *newsModel;
@property (copy,  nonatomic ) NSString  *keyword;
@property (strong, nonatomic) UILabel *titleLbl;


+ (SearchNewsCell *)cellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
