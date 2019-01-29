//
//  QMPIPOQueueCell.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/9/5.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IPOModel;
@interface QMPIPOQueueCell : UITableViewCell
@property (nonatomic, strong) IPOModel *ipoModel;
+ (instancetype)ipoQueueCellWithTableView:(UITableView *)tableView;
@end


@interface QMPIPOQueueTableHeaderView : UITableViewHeaderFooterView
@end
