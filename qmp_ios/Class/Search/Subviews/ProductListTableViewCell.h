//
//  ProductListTableViewCell.h
//  qmp_ios
//
//  Created by Molly on 16/8/23.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchCompanyModel.h"
@interface ProductListTableViewCell : UITableViewCell

@property (strong, nonatomic) NSString *groupId;
@property (strong, nonatomic) NSString *productId;
@property (strong, nonatomic) UIButton *addBtn;
@property (strong, nonatomic) UIButton *hasAddedBtn;
@property (strong, nonatomic) SearchCompanyModel *model;
-(void)refreshUI:(SearchCompanyModel *)model;

@end
