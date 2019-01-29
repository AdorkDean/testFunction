//
//  AddSearchJigouCell.h
//  qmp_ios
//
//  Created by QMP on 2017/11/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrganizeItem.h"

@interface AddSearchJigouCell : UITableViewCell
@property (strong, nonatomic) NSString *groupId;
@property (strong, nonatomic) NSString *productId;
@property (strong, nonatomic) UIButton *addBtn;
@property (strong, nonatomic) UIButton *hasAddedBtn;
@property (strong, nonatomic) OrganizeItem *model;

-(void)refreshUI:(OrganizeItem *)model;

@end
