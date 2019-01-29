//
//  UpgradeVersionView.m
//  qmp_ios
//
//  Created by QMP on 2018/7/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "UpgradeVersionView.h"


@implementation UpgradeVersionView

-(void)awakeFromNib{
    [super awakeFromNib];
    
    self.bgWhiteV.layer.cornerRadius = 10.0;
    self.bgWhiteV.layer.masksToBounds = YES;
    self.bgWhiteV.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.45];
    
    self.updateBtn.layer.masksToBounds = YES;
    self.updateBtn.layer.cornerRadius = 39/2.0;
    self.updateBtn.layer.borderColor = BLUE_TITLE_COLOR.CGColor;
    self.updateBtn.layer.borderWidth = 2.0;
    [self.updateBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    
    self.versionLab.backgroundColor = BLUE_BG_COLOR;
    self.versionLab.layer.masksToBounds = YES;
    self.versionLab.layer.cornerRadius = 13.5;
    self.versionLab.text = [NSString stringWithFormat:@"V%@",VERSION];

    self.closeView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    [self.closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.updateBtn addTarget:self action:@selector(gotoUpdate) forControlEvents:UIControlEventTouchUpInside];
}


+ (void)showUpgradView:(NSString*)content showClose:(BOOL)showClose version:(NSString*)version{
    
    UpgradeVersionView *view = [[BundleTool commonBundle]loadNibNamed:@"UpgradeVersionView" owner:nil options:nil].lastObject;
    view.frame = KEYWindow.bounds;
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc]init];
    paraStyle.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithAttributedString: [content stringWithParagraphlineSpeace:5 textColor:COLOR2D343A textFont:[UIFont systemFontOfSize:15]]];
    [attText addAttributes:@{NSParagraphStyleAttributeName:paraStyle} range:NSMakeRange(0, content.length)];
    view.contentLab.attributedText = attText;
//    view.contentLab.text = content;
    view.closeView.hidden = !showClose;
    view.versionLab.text = [NSString stringWithFormat:@"V%@",version];
    [KEYWindow addSubview:view];
}

- (void)closeBtnClick{
    
    [self removeFromSuperview];
}

- (void)gotoUpdate{
    
    NSString *str = APPSTORE;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];

}


@end
