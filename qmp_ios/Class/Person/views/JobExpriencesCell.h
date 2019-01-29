//
//  JobExpriencesCell.h
//  qmp_ios
//
//  Created by QMP on 2017/11/27.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZhiWeiModel.h"
#import "EducationExpModel.h"
#import "WinExperienceModel.h"

@interface JobExpriencesCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UILabel *zaizhiLab;
@property (weak, nonatomic) IBOutlet UIView *topLine;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topEdge;
@property(nonatomic,strong) ZhiWeiModel *exprienceM;
@property(nonatomic,strong) EducationExpModel *eduExprienceM;
@property(nonatomic,strong) WinExperienceModel *winExprienceM; //获奖经历
@property(nonatomic,strong) WinExperienceModel *proOrgPrizeM; //获奖经历

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabRightEdge;

+ (instancetype)cellWithTableView:(UITableView*)tableView;


@property(nonatomic,strong) UIColor *iconColor;
@end
