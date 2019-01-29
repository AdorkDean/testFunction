//
//  RelateCompanyCell.h
//  qmp_ios
//
//  Created by QMP on 2018/2/8.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RelateCompanyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;

- (void)setCompanyName:(NSString*)name titleBgColor:(UIColor*)titleBgColor;

+ (RelateCompanyCell *)cellWithTableView:(UITableView *)tableView;
@end
