//
//  MemberPersonCell2.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/3/13.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManagerItem.h"
#import "PersonModel.h"
@class InsetsLabel;

@interface MemberPersonCell2 : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property(nonatomic,assign) BOOL isCompany;

@property(nonatomic,strong) ManagerItem *manager;
@property(nonatomic,strong) UIColor  *iconColor;
@property(nonatomic,strong) PersonModel *person; //目前与之相关联的 SchoolPersonController 
@property (weak, nonatomic) IBOutlet InsetsLabel * statusLabel;
@property (nonatomic, copy) NSString * statusTxt;
@end
