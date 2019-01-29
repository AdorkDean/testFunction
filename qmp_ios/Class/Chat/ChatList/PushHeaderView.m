//
//  PushHeaderView.m
//  qmp_ios
//
//  Created by QMP on 2018/1/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PushHeaderView.h"
@interface PushHeaderView()
{
    __weak IBOutlet UIImageView *_sysMsgImgV;
    
    __weak IBOutlet UIImageView *_applyImgV;
    __weak IBOutlet UIImageView *_userActiImgV;
}
@end

@implementation PushHeaderView

-(void)awakeFromNib{
    [super awakeFromNib];
    
    _sysMsgImgV.image = [BundleTool imageNamed:@"sysmsg_notification"];
    self.systemMsgRedV.layer.masksToBounds = YES;
    self.systemMsgRedV.layer.cornerRadius = 5.5;
    
    self.userActivityRedV.layer.masksToBounds = YES;
    self.userActivityRedV.layer.cornerRadius = 5.5;
    _userActiImgV.image = [BundleTool imageNamed:@"sysmsg_interaction"];
//    self.applyRedV.layer.cornerRadius = 5.5;
//    self.applyRedV.clipsToBounds = YES;
    _applyImgV.image = [BundleTool imageNamed:@"sysmsg_exchangcard"];

    self.systemMsgRedV.hidden = YES;
    self.userActivityRedV.hidden = YES;
//    self.applyRedV.hidden = YES;
    self.systemMsgRedV.backgroundColor = RED_TEXTCOLOR;
    self.userActivityRedV.backgroundColor = RED_TEXTCOLOR;
//    self.applyRedV.backgroundColor = RED_TEXTCOLOR;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.systemMsgRedV.layer.cornerRadius = 5.5;
    self.userActivityRedV.layer.cornerRadius = 5.5;
//    self.applyRedV.layer.cornerRadius = 5.5;
}
@end
