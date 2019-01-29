//
//  SearchRegistCell.h
//  qmp_ios
//
//  Created by QMP on 2017/11/15.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchProRegisterModel.h"

@interface SearchRegistCell : UITableViewCell
@property (copy, nonatomic) NSString *keyWord;

@property(nonatomic,strong)SearchProRegisterModel *registModel;

@property(nonatomic,strong) UIColor *nameIconColor;

@end
