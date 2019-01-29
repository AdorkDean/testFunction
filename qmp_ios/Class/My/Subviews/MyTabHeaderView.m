//
//  MyHeaderView.m
//  qmp_ios
//
//  Created by QMP on 2018/1/9.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MyTabHeaderView.h"

@implementation MyTabHeaderView

-(void)awakeFromNib{
    [super awakeFromNib];
    
    self.homePageLab.layer.cornerRadius = 8.5;
    self.homePageLab.layer.masksToBounds = YES;
    self.homePageLab.backgroundColor = [UIColor whiteColor];
    
    [self.rzStatusLbl labelWithFontSize:10 textColor:BLUE_TITLE_COLOR cornerRadius:2 borderWdith:0.5 borderColor:BLUE_TITLE_COLOR];
}


@end
