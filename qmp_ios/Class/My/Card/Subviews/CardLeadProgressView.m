//
//  CardLeadProgressView.m
//  qmp_ios
//
//  Created by QMP on 2018/4/11.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "CardLeadProgressView.h"

@interface CardLeadProgressView()

@end

@implementation CardLeadProgressView

-(void)awakeFromNib{
    [super awakeFromNib];
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    
    self.whiteView.layer.masksToBounds = YES;
    self.whiteView.layer.cornerRadius = 10;
    self.whiteView.layer.borderColor = BORDER_LINE_COLOR.CGColor;
    self.whiteView.layer.borderWidth = 1;
}

- (IBAction)chaBtnClick:(id)sender {
    [self removeFromSuperview];
}

@end
