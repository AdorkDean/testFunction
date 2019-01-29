//
//  EducationCell.h
//  qmp_ios
//
//  Created by QMP on 2017/11/27.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EducationExpModel.h"

@interface EducationCell : UITableViewCell
@property(nonatomic,strong) UIButton *editBtn;

@property(nonatomic,strong) UIColor *degreeColor;
//工作
@property(nonatomic,strong) ZhiWeiModel *exprienceM;
@property(nonatomic,strong) UIColor *iconColor;


//教育
@property(nonatomic,strong) EducationExpModel *educationM;

@end
