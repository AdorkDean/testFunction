//
//  MyHeaderView.h
//  qmp_ios
//
//  Created by QMP on 2018/1/9.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InsetsLabel.h"

@interface MyTabHeaderView : UIView


@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *loginInfoLbl;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet UILabel *bindPhoneLab;
@property (weak, nonatomic) IBOutlet UIButton *iconButton;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UILabel *infoLbl;
@property (weak, nonatomic) IBOutlet UIButton *arrowBtn;
@property (weak, nonatomic) IBOutlet UILabel *homePageLab;

@property (weak, nonatomic) IBOutlet InsetsLabel *rzStatusLbl;

@end
