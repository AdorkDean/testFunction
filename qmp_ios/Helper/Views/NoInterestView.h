//
//  NoInterestView.h
//  qmp_ios
//
//  Created by QMP on 2018/4/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMTextView.h"

@interface NoInterestView : UIView

@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)HMTextView *textview;

@property (nonatomic,strong)UILabel *lab;//提示
@property (nonatomic,strong)UIButton *feedbackAllBtn;
@property (nonatomic,weak)UIViewController *VC;
@property (nonatomic,strong)NSMutableArray *selectedBtnMArr;
@property (nonatomic,strong)UIButton *qRButton;
@property (nonatomic,strong)NSDictionary * infoDic;//反馈的模块
@property (nonatomic,copy)void(^submitBtnClick)(NSString *liyou, NSString *detail);


- (instancetype)initWithAlertViewTitles:(NSArray *)mArr  viewcontroller:(UIViewController *)vc;

@end
