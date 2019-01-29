//
//  CompanysDetailRegisterInfoCell.h
//  qmp_ios
//
//  Created by qimingpian10 on 2016/12/12.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface CompanysDetailRegisterInfoCell : UITableViewCell

@property (strong, nonatomic) UIButton *searchBtn;
@property(nonatomic,strong) UILabel *lab;//注册资本

-(void)refreshUI:(NSString *)dic andKey:(NSString *)key;

@end
