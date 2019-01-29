//
//  QMPIPOLibraryCell.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/9/5.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SmarketEventModel;
@interface QMPIPOLibraryCell : UITableViewCell
@property (nonatomic, strong) SmarketEventModel *ipoModel;
+ (instancetype)ipoLibraryCellWithTableView:(UITableView *)tableView;
@end

@interface QMPIPOLibraryTableHeaderView : UITableViewHeaderFooterView
@end
