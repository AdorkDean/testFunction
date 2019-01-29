//
//  OnlyContentController.m
//  qmp_ios
//
//  Created by QMP on 2018/1/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "OnlyContentController.h"

@interface OnlyContentController ()

@end

@implementation OnlyContentController
-(instancetype)init{
    OnlyContentController *vc = [[OnlyContentController alloc]initWithNibName:@"OnlyContentController" bundle:[BundleTool commonBundle]];
    return vc;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_navTitle) {
        self.title = @"推送详情";
    }
    
    NSString *title = [PublicTool isNull:self.dic[@"title"]] ? @"" : self.dic[@"title"];
    if (![PublicTool isNull:title]) {
        
        self.timeTopHeight.constant = 17;
        self.titleLab.attributedText = [title stringWithParagraphlineSpeace:6 textColor:NV_TITLE_COLOR textFont:[UIFont systemFontOfSize:20]];

    }else{
        
        self.timeTopHeight.constant = -40;
    }
    
    self.timeLab.text = [[[self.dic[@"send_time"] componentsSeparatedByString:@" "] firstObject] stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    
    self.contentLab.attributedText = [self.dic[@"content"] stringWithParagraphlineSpeace:6 textColor:H5COLOR textFont:[UIFont systemFontOfSize:16 weight:UIFontWeightLight]];
}

- (void)setNavTitle:(NSString *)navTitle{
    _navTitle = navTitle;
    self.title = _navTitle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
