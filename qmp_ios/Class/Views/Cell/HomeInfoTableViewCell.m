//
//  HomeInfoTableViewCell.m
//  qmp_ios
//
//  Created by Molly on 16/8/18.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "HomeInfoTableViewCell.h"
#import "CreateProController.h"

@implementation HomeInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    [self.createBtn addTarget:self action:@selector(createProBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.createBtn.layer.masksToBounds = YES;
    self.createBtn.layer.cornerRadius = 20;
    self.createBtn.backgroundColor = BLUE_BG_COLOR;
    [self.createBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.createBtn.hidden = YES;
    self.subInfoLab.hidden = YES;
}


- (void)createProBtnClick{
    
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    if (![self.createBtn.titleLabel.text isEqualToString:@"创建项目"]) {
        return;
    }
    
    CreateProController *prodVC = [[CreateProController alloc]init];
   
    [[PublicTool topViewController].navigationController  pushViewController:prodVC animated:YES]; //presentViewController:navc animated:YES completion:nil];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
