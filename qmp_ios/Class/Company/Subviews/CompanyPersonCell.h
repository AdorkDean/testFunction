//
//  CompanyPersonCell.h
//  qmp_ios
//
//  Created by QMP on 2018/3/13.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManagerItem.h"
#import "SearchPerson.h"

@interface CompanyPersonCell : UITableViewCell

@property(nonatomic,strong) ManagerItem *manager;
@property(nonatomic,strong) UIColor  *iconColor;
@property(nonatomic,strong) SearchPerson *person; //目前与之相关联的 SchoolPersonController 
@property(nonatomic,strong) UIButton *chatBtn;

@end
