//
//  BindCompanyItem.m
//  qmp_ios
//
//  Created by QMP on 2018/4/4.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BindCompanyItem.h"

@implementation BindCompanyItem

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.loginView.layer.masksToBounds = YES;
    self.loginView.layer.cornerRadius = 3;
    self.loginView.contentMode = UIViewContentModeScaleAspectFit;
    self.loginView.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    self.loginView.layer.borderWidth = 0.5;

}

@end
