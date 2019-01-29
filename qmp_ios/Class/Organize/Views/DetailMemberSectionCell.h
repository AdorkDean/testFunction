//
//  DetailMemberSectionCell.h
//  qmp_ios
//
//  Created by QMP on 2018/8/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailMemberSectionCell : UITableViewCell

+ (DetailMemberSectionCell *)memberSectionCellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) NSArray *memberArray;
@end
