//
//  ProductHomeCell.h
//  qmp_ios
//
//  Created by QMP on 2018/3/21.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StarProductsModel.h"


@interface ProductHomeCell : UITableViewCell

@property(nonatomic,strong) StarProductsModel *productM;
@property(nonatomic,strong) UIColor *iconColor;

@end
