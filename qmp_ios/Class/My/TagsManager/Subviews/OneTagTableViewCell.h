//
//  OneTagTableViewCell.h
//  qmp_ios
//
//  Created by molly on 2017/5/19.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchCompanyModel.h"

@interface OneTagTableViewCell : UITableViewCell
- (void)initData:(SearchCompanyModel *)model;
@end
