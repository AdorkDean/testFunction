//
//  ProductListCell.h
//  qmp_ios
//
//  Created by QMP on 2017/12/29.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StarProductsModel.h"


@interface ProductListCell : UITableViewCell

@property(nonatomic,strong) StarProductsModel *productM;
@property(nonatomic,strong) UIColor *iconColor;

@end
