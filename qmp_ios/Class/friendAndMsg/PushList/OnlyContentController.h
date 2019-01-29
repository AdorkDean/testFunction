//
//  OnlyContentController.h
//  qmp_ios
//
//  Created by QMP on 2018/1/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

@interface OnlyContentController : BaseViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeTopHeight;

@property(nonatomic,strong) NSDictionary *dic;
@property (nonatomic, copy) NSString * navTitle;

@end
