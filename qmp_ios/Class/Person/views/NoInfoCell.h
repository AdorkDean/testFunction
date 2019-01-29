//
//  NoInfoCell.h
//  qmp_ios
//
//  Created by QMP on 2018/1/29.
//  Copyright © 2018年 Molly. All rights reserved.
//工作 学校

#import <UIKit/UIKit.h>

@interface NoInfoCell : UITableViewCell

@property (copy, nonatomic) NSString *btnText;
@property(nonatomic,assign) BOOL isMy;
@property (strong, nonatomic) UILabel *tipLab; //左上角文案

@property (strong, nonatomic) UIButton *addBtn;
+ (instancetype)cellWithTableView:(UITableView*)tableView reuseIndentifier:(NSString*)identifier;
- (void)unAuthCellMsg;
@end
